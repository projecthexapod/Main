from leg_logger import logger
import math
from math_utils import saturate
import time_sources
import scipy

class PidController:
    def __init__(self, kp, ki, kd, soft_min, soft_max):
        self.kp = kp
        self.ki = ki
        self.kd = kd

        self.soft_min = soft_min
        self.soft_max = soft_max
        
        self.max_movement_rate = 100
        
        self.max_error_growth_time = 1e9
        self.max_limit_cycle = 1e9

        # NOTE: it is important that these three variables are floating point to avoid truncation
        self.prev_error = 0.0
        self.prev_desired_pos = 0.0
        self.integral_error_accumulator = 0.0
        
        #hysteretic limits for rising/falling edge detection
        self.hyst_low_limit = 0.0
        self.hyst_high_limit = 0.0
        
        self.peak_detector=HystereticPeakDetector(0.0, self.hyst_low_limit,
        self.hyst_high_limit, math.pi/20)

    def update(self, desired_pos, measured_pos):
        if math.isnan(desired_pos):
            logger.error("PidController.update: NaN where aN expected!",
                        desired_pos=desired_pos,
                        measured_pos=measured_pos,
                        soft_min=self.soft_min,
                        soft_max=self.soft_max,
                        bad_value="desired_pos")
            raise ValueError("PidController: desired_pos cannot be NaN.")
        if math.isnan(measured_pos):
            logger.error("PidController.update: NaN where aN expected!",
                        desired_pos=desired_pos,
                        measured_pos=measured_pos,
                        soft_min=self.soft_min,
                        soft_max=self.soft_max,
                        bad_value="measured_pos")
            raise ValueError("PidController: measured_pos cannot be NaN.")

        if self.soft_min > measured_pos or measured_pos > self.soft_max:
            logger.error("PidController.update: Measured position outside of soft range!",
                        desired_pos=desired_pos,
                        measured_pos=measured_pos,
                        soft_min=self.soft_min,
                        soft_max=self.soft_max,
                        bad_value=measured_pos)
            raise ValueError("PidController: Measured position out of soft range!")
        
        # bound the desired position
        desired_pos = self.boundDesiredPosition(desired_pos)

        error = desired_pos - measured_pos
        delta_time = time_sources.global_time.getDelta()

        self.peak_detector.update(error)
        
        if self.peak_detector.hasConverged():
            if self.peak_detector.isUnstable():
                warningstring=("PidController: Maximum error for the"+
                        " desired point has increased for %d seconds,"+
                        " but is within resolved range.  Might be unstable." %
                        self.peak_detector.getResolveTime() )
                logger.warning(warningstring,
                        desired_pos=desired_pos,
                        measured_pos=measured_pos,
                        soft_min=self.soft_min,
                        soft_max=self.soft_max,
                        error=error,
                        bad_value=error)
            elif self.peak_detector.isLimitCycle():
                warningstring=("PidController: Maximum error for the"+
                        " desired point has increased once or more for %d seconds,"+
                        " but is within resolved range.  Might be unstable." %
                        self.peak_detector.getResolveTime() )
                logger.warning(warningstring,
                        desired_pos=desired_pos,
                        measured_pos=measured_pos,
                        soft_min=self.soft_min,
                        soft_max=self.soft_max,
                        error=error,
                        bad_value=error)
        else:
            if self.peak_detector.isUnstable():
                errorstring=("PidController: Maximum error for the desired point"+ 
                        "has increased for %d seconds.  System potentially unstable." %
                        self.peak_detector.getResolveTime() )
                logger.error(errorstring,
                        desired_pos=desired_pos,
                        measured_pos=measured_pos,
                        soft_min=self.soft_min,
                        soft_max=self.soft_max,
                        error=error,
                        bad_value=error)
                raise ValueError(errorstring)
            elif self.peak_detector.isLimitCycle():
                errorstring=("PidController: Controller has not resolved"+ 
                "over %d seconds.  System potentially in a limit cycle." %
                self.peak_detector.getResolveTime() )
                logger.error(errorstring,
                        desired_pos=desired_pos,
                        measured_pos=measured_pos,
                        soft_min=self.soft_min,
                        soft_max=self.soft_max,
                        error=error,
                        bad_value=error)
                raise ValueError(errorstring)
        
        self.integral_error_accumulator += self.ki * error * delta_time
        derivative_error = (error - self.prev_error) / delta_time

        self.prev_error = error
        self.prev_desired_pos = desired_pos
        
        actuator_command = self.kp * error + self.integral_error_accumulator + self.kd * derivative_error
        actuator_command=self.boundActuatorCommand(actuator_command, measured_pos, delta_time)
        
        return actuator_command

    def isErrorInBounds(self, error, measured_pos):
        """tests whether or not the error signal is within reasonable range
        not checking for NaN, since both desired and measured position
        are tested for that
        """
        
        #makes sure the error is bounded by a single leg rotation
        error = error%(2*math.pi)
        
        #is error within available soft range?
        if error>(measured_pos-self.soft_min) or error>(self.soft_max-measured_pos):
            logger.error("PidController.isErrorInBounds: error out of soft bounds.",
                        error=error,
                        measured_pos=measured_pos)
            raise ValueError("Error signal points to a position out of soft bounds.")
        return error
    
    def boundDesiredPosition(self,desired_pos):
        #caps desired position to soft movement range
        bounded_pos=saturate(desired_pos,self.soft_min,self.soft_max)
        if desired_pos<self.soft_min or desired_pos>self.soft_max:
            raise ValueError("PidController.boundDesiredPosition:"+
        	    	" desired position out of soft bounds")
        return bounded_pos
    
    def boundActuatorCommand(self, actuator_command, measured_pos, delta_time):
        #bound actuator command to available range of command which don't
        #move the actuator outside of available soft range
        soft_min_command=self.soft_min - measured_pos
        soft_max_command=self.soft_max - measured_pos
        actuator_command=saturate(actuator_command,soft_min_command,soft_max_command)
        if abs(actuator_command - measured_pos)/delta_time > self.max_movement_rate:
            raise ValueError("PidController: Actuator command would cause"+
            "joint to move at unsafe rate.")
        return actuator_command

class HystereticPeakDetector:
    def __init__(self, start_value, hyst_low_limit, hyst_high_limit, resolved_threshold):
        self.historylength=100
        
        #Class Attributes to determine when a state transition has happened
        self.hyst_high_limit=hyst_high_limit
        self.hyst_low_limit=hyst_low_limit
        
        self.NO_EDGE_DETECTED=0
        self.RISING_EDGE=1
        self.FALLING_EDGE=2
        
        #Class Attribute to determine when
        self.resolved_threshold=resolved_threshold
        
        self.prev_pos=start_value
        
        self.reset()
                    
    def reset(self):
        #resets peaks and troughs, while maintaining state for current position
        self.peaks=[]
        self.troughs=[]
        self.peak=self.prev_pos
        self.trough=self.prev_pos
        self.edgetype=0
        self.resolve_time=0.0
        
        #Dictionary of flags for different potential system states
        self.flags={"unstable":False,
                    "limit_cycle":False,
                    "resolving":False,
                    "resolved":False}

    def isUnstable(self):
        return self.flags["unstable"]
    
    def isLimitCycle(self):
        return self.flags["limit_cycle"]
    
    def isResolving(self):
        return self.flags["resolving"]
    
    def hasConverged(self):
        return self.flags["resolved"]
        
    def update(self, measured_pos):
        
        if self.edgetype==self.NO_EDGE_DETECTED:
            ##INIT STATE - for startup only
            if measured_pos-self.trough>self.hyst_high_limit:
                self.edgetype=self.RISING_EDGE
            elif measured_pos-self.peak<self.hyst_low_limit:
                self.edgetype=self.FALLING_EDGE
        elif self.edgetype==self.RISING_EDGE:
            ##RISING EDGE STATE
            self.peak=max(self.peak, measured_pos)
            if measured_pos-self.peak<self.hyst_low_limit:
                self.edgetype=self.FALLING_EDGE
                self.peaks.append(self.peak)
                #reset trough so it can accumulate properly in next state
                self.trough=measured_pos
        elif self.edgetype==self.FALLING_EDGE:
            ##FALLING EDGE STATE
            self.trough=min(self.trough, measured_pos)
            if measured_pos-self.trough>self.hyst_high_limit:
                self.edgetype=self.RISING_EDGE
                self.troughs.append(self.trough)
                #reset peak so it can accumulate properly in next state
                self.peak=measured_pos
        
        #truncate peak/trough history
            for i in [self.peaks, self.troughs]:
                if len(i)>self.historylength:
                    i.pop(0)
        
        self.resolve_time+=time_sources.global_time.getDelta()			
        self.prev_pos=measured_pos
        
        #check for resolution, instability, limit cycles
        self.updateStates()
    
    def getEdgeType(self):
        return self.edgetype
    
    def getResolveTime(self):
        return self.resolve_time
    
    def updateStates(self):
        peak_deltas = scipy.diff(self.peaks)
        trough_deltas = scipy.diff(self.troughs)
        
        [unstable, limit_cycle, resolving, resolved]=[True, True, True, True]
        

        #only unstable if error always rises
        unstable = (peak_deltas > 0.0).all() or (trough_deltas < 0.0).all()
        #only resolving if error is always decreasing
        resolving = (peak_deltas < 0.0).all() and (trough_deltas > 0.0).all()
        #in a limit cycle if error ever rises
        limit_cycle = not resolving and not unstable
            
        #only resolved if both final peak and trough are below
        #resolved threshold
        resolved=( (self.peaks[-1] < self.resolved_threshold) and
        		(self.troughs[-1] > -self.resolved_threshold) )
        self.flags["unstable"]=unstable
        self.flags["limit_cycle"]=limit_cycle
        self.flags["resolving"]=resolving
        self.flags["resolved"]=resolved
