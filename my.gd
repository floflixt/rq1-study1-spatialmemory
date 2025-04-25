extends Node

## This autoload script contains some custom helper functions.
##
## MY Functions

###################################################################################################

## function to make string of coordinates from vector
func vec_to_str(vec: Vector3) -> String:
	var x: float = snapped(vec.x, 0.001)
	var y: float = snapped(vec.y, 0.001)
	var z: float = snapped(vec.z, 0.001)
	return str(x, "\n", y, "\n", z)

## function to make string from transform
func transf_to_str(tr: Transform3D) -> String:
	return str("  X  -  Y  -  Z  -  O\n" +\
	str(snapped(tr.basis.x.x, 0.001)) + " - " + str(snapped(tr.basis.y.x, 0.001)) + " - " + str(snapped(tr.basis.z.x, 0.001)) + " - " + str(snapped(tr.origin.x, 0.001)) + "\n" +\
	str(snapped(tr.basis.x.y, 0.001)) + " - " + str(snapped(tr.basis.y.y, 0.001)) + " - " + str(snapped(tr.basis.z.y, 0.001)) + " - " + str(snapped(tr.origin.y, 0.001)) + "\n" +\
	str(snapped(tr.basis.x.z, 0.001)) + " - " + str(snapped(tr.basis.y.z, 0.001)) + " - " + str(snapped(tr.basis.z.z, 0.001)) + " - " + str(snapped(tr.origin.z, 0.001)))

	
## function to make a csv-like string for saving transform3D
func transf_to_csv(tr: Transform3D) -> String:
	return str(str(Time.get_ticks_msec()) + "," +\
	str(snapped(tr.basis.x.x, 0.001)) + "," + str(snapped(tr.basis.y.x, 0.001)) + "," + str(snapped(tr.basis.z.x, 0.001)) + "," + str(snapped(tr.origin.x, 0.001)) + "," +\
	str(snapped(tr.basis.x.y, 0.001)) + "," + str(snapped(tr.basis.y.y, 0.001)) + "," + str(snapped(tr.basis.z.y, 0.001)) + "," + str(snapped(tr.origin.y, 0.001)) + "," +\
	str(snapped(tr.basis.x.z, 0.001)) + "," + str(snapped(tr.basis.y.z, 0.001)) + "," + str(snapped(tr.basis.z.z, 0.001)) + "," + str(snapped(tr.origin.z, 0.001)) + "\n")


## function to calculate the distance between two transforms
func dist_transf(tr1 : Transform3D, tr2: Transform3D) -> float:
	return tr1.origin.distance_to(tr2.origin)
