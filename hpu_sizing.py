from pylab import *


# The Cartesian position type is a numpy array
def CP(x,y,z):
	return array([x,y,z])

def trans(H, cp):
	cp2 = H * matrix(append(cp,1.0)).T
	assert abs(cp2[3] - 1.0) < 1e-10, "ERROR: 4th coefficient should be 1.0, not %f" % cp2[3]
	return array(cp2)[:-1,0]


# Kinematics specified using simplified DH parameters as defined on page 76 of Spong,H,V:
#   The local frame is attached to the *end* of each link.
#   Joint angle (theta) is about previous link's Z-axis.
#   Length is the link's extent in the previous link's X-axis if theta is zero.
#   Rotation sets the Z-axis correctly for the next joint.
# To get from Frame i-1 to Frame i:
#   1. Rotate about Z by theta[i]
#   2. Translate along X by length[i]
#   3. Rotate about X by rotation[i]
class Link:
	def __init__(self, length, rotation):
		self.l = length  # m
		self.r = rotation  # rad
		self.sr = sin(self.r)
		self.cr = cos(self.r)

		self.setTheta(0.0)
		
		self.pLink = None  # Previous link in the chain
		self.dLink = None  # Next link in the chain
	
	def setProximalLink(self, link):
		if self.pLink != None:
			self.pLink.dLink = None
		self.pLink = link
		if link != None:
			link.dLink = self
	def setDistalLink(self, link):
		link.setProximalLink(self)
	
	def getTheta(self):
		return self.t
	def setTheta(self, theta):
		self.t = theta
		
		st = sin(self.t)
		ct = cos(self.t)
		
		sr = self.sr
		cr = self.cr
		
		l = self.l
		
		# Homogeneous transform from proximal frame to local frame
		self.l2p = matrix(
			[[ct, -st*cr,  st*sr, l*ct],
			 [st,  ct*cr, -ct*sr, l*st],
			 [ 0,     sr,     cr,    0],
			 [ 0,      0,      0,    1]]
			)
		
		# Inverse
		self.p2l = self.l2p.I
		
	def toProximal(self, cp):
		return trans(self.l2p, cp)
		
	def toWorld(self, cp):
		return self.pLink.toWorld(self.toProximal(cp))


class Cylinder:
	def __init__(self, bore, stroke, retractedLength, link1Index, attachmentPoint1, link2Index, attachmentPoint2):
		self.bore = bore  # m^2
		self.stroke = stroke  # m
		self.rl = retractedLength  # m
		
		self.l1 = link1Index
		self.ap1 = attachmentPoint1  # In link1 frame
		self.l2 = link2Index
		self.ap2 = attachmentPoint2  # In link2 frame
	
	def volume(self):
		l = norm(self.l1.toWorld(self.ap1) - self.l2.toWorld(self.ap2))
		if l < self.rl  or  l > self.rl + self.stroke:
			raise ValueError("Cylinder length out of bounds: %f (min=%f, max=%f)" % (l, self.rl, self.rl + self.stroke))
		return (l - self.rl)*self.bore * 1000.0  # Convert to liters

	def draw(self):
		ends = array([self.l1.toWorld(self.ap1), self.l2.toWorld(self.ap2)])
		
		subplot(121)  # X-Y
		plot(ends[:,0], ends[:,1], 'b.-', linewidth=2)
		subplot(122)  # X-Z
		plot(ends[:,0], ends[:,2], 'b.-', linewidth=2)

		
class Leg:
	def __init__(self, links, cylinders):
		self.links = list(links)
		self.cylinders = list(cylinders)
		self.dof = len(self.links)
		assert self.dof == 3,  "Legs must have exactly three links"
		assert len(self.cylinders) == self.dof, "Legs must have an equal number of cylinders and links"
		
		# Put the kinematic chain together
		self.pLink = None
		self.links[0].setProximalLink(self)
		for j in range(self.dof - 1):
			self.links[j].setDistalLink(self.links[j+1])
		
		# Replace link indices with links
		for c in self.cylinders:
			if c.l1 == -1:
				c.l1 = self
			else:
				c.l1 = self.links[c.l1]
			if c.l2 == -1:
				c.l2 = self
			else:
				c.l2 = self.links[c.l2]
	
	# Forward kinematics
	def getAngles(self):
		return array(map(Link.getTheta, self.links))
	def setAngles(self, *args):
		map(Link.setTheta, self.links, args)
	
	# Inverse kinematics
	def getFootPos(self):
		return self.links[-1].toWorld(CP(0,0,0))
	def setFootPos(self, cp):
		l1 = self.links[1].l
		l2 = self.links[2].l
		x = cp[0]
		y = cp[1]
		z = cp[2]

		# Ignoring joint limits, we can reach any pose within a sphere centered at the shoulder.
		# (This is false, but it's a place to start.)
		if norm(cp) >= l1 + l2:
			raise ValueError("Position unachievable: |%f %f %f| = %f > %f = %f + %f" % (x,y,z, norm(cp), l1 + l2, l1, l2))

		q = zeros(3)
		
		# First, do the easy one
		q[0] = arctan2(y, x)
		
		# Since the other two links are planar, we can use page 23 of SHV
		r = (x**2 + y**2)**0.5
		D = (r**2 + z**2 - l1**2 - l2**2) / (2*l1*l2)
		
		q[2] = -abs(arctan( (1-D**2)**0.5 / D ))  # Prefer the elbow-up solution
		q[1] = arctan(z/r) - arctan( (l2*sin(q[2])) / (l1 + l2*cos(q[2])) )
		
		self.setAngles(*q)
	
	def toWorld(self, cp):
		return cp  # Stub. No Body yet.
	
	def draw(self):
		o = CP(0,0,0)
		origins = zeros((self.dof+1, 3))
		
		origins[0,:] = self.toWorld(o)
		for j in range(self.dof):
			origins[j+1,:] = self.links[j].toWorld(o)
		
		subplot(121)  # X-Y
		plot(origins[:,0], origins[:,1], 'ro-', linewidth=8)
		subplot(122)  # X-Z
		plot(origins[:,0], origins[:,2], 'ro-', linewidth=8)
		
		#map(Cylinder.draw, self.cylinders)

#class Body:
#	def __init__(self, *args):
#		self.legs = list(args)
#		self.nLegs = len(self.legs)
#		
#		# Connect legs to body
#		for leg in self.legs:
#			leg.links[0].setProximalLink(self)




# Main
B = pi*0.01**2
S = 1.0
RL = 1.0

leg = Leg(
			[Link(0.0, pi/2), Link(1.0, 0.0), Link(0.5, 0.0)],
			[
				Cylinder(B,S,RL, -1, CP(0, 0.5, 0), 1, CP(-0.5, 0, 0)),
				Cylinder(B,S,RL, -1, CP(0, 0, -0.5), 1, CP(-0.5, 0, 0)),
				Cylinder(B,S,RL,  1, CP(-0.25, 0, 0), 2, CP(-0.25, 0, 0))
			]
		)

#leg.setAngles(0,pi/8,-pi/4)
leg.setFootPos(CP(1.25,0,0))
print leg.getFootPos()
print leg.getAngles()

leg.draw()
subplot(121)
title("Top down view")
xlabel("X (m)")
ylabel("Y (m)")
axis([-1.75, 1.75, -1.75, 1.75])
subplot(122)
title("Side view")
xlabel("X (m)")
ylabel("Z (m)")
axis([-1.75, 1.75, -1.75, 1.75])
#show()


