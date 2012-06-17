from ControlsKit import time_sources, leg_model, Paths, leg_logger
from ControlsKit.Paths import TrapezoidalFootMove
from scipy import zeros, append
from ControlsKit.math_utils import array, NUM_LEGS

class TrapezoidalSitStand:
    """This path moves the hexapod body straight up or down with a trapezoidal velocity profile
    """
    
    #TODO: check to make sure all legs are on the ground first
    
    def __init__(self, body_model, final_height, max_velocity, acceleration):
        leg_logger.logger.info("New path.", path_name="TrapezoidalSitStand",
                    final_height=final_height, max_velocity=max_velocity,
                    acceleration=acceleration)
        
        self.body = body_model
        self.final_foot_positions = zeros((3, NUM_LEGS))
        self.feet_path = []
        
        current_positions = self.body.getFootPositions()
        for i in range (NUM_LEGS):
            self.final_foot_positions[2,i] = final_height
        for i in range (NUM_LEGS):
            self.feet_path = append(self.feet_path, TrapezoidalFootMove(self.body.getLegs()[i], self.final_foot_positions[:,i], max_velocity, acceleration))
        
        self.done = False
    
    def isDone(self):
        return self.done    
    
    def update(self):
        if not self.done:
            #logically and all of the isdone results from the trapezoidal foot move paths
            self.done = reduce(lambda x,y: x and y, map(TrapezoidalFootMove.isDone, self.feet_path))
            return [self.feet_path[i].update() for i in range (NUM_LEGS)]
