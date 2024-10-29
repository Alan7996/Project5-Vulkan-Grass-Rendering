## Vulkan Grass Rendering

Author: Alan Lee ([LinkedIn](https://www.linkedin.com/in/soohyun-alan-lee/))

This project is a Vulkan grass renderer showcasing physically based simulation of grass blade movements under various forces and collisions.

The algorithm is based on a real-time grass rendering paper by Klemens Jahrmann and Michael Wimmer and accounts for gravity, wind, and recovery forces as well as dynamic culling for maximum performance.

## Contents

* `src/` C++/Vulkan source files.
  * `shaders/` glsl shader source files
  * `images/` images used as textures within graphics pipelines
* `external/` Includes and static libraries for 3rd party libraries.

## Running the code

The codebase requires the [Vulkan SDK](https://vulkan.lunarg.com/) and a [Vulkan driver](https://developer.nvidia.com/vulkan-driver) appropriate to your graphics card to have been installed to be ran.

Configure and generate build files using provided cmakelists.

Vulkan validation layer is turned on by default for `debug` mode, but it is not enabled in `release` mode.

## Analysis

### Grass Representation

![](img/blade_model.jpg)

In this project, grass blades will be represented as Bezier curves while performing physics calculations and culling operations. 

Each Bezier curve has three control points.
* `v0`: the position of the grass blade on the geomtry
* `v1`: a Bezier curve guide that is always "above" `v0` with respect to the grass blade's up vector
* `v2`: a physical guide for which we simulate forces on

We also need to store per-blade characteristics that will help us simulate and tessellate our grass blades correctly.
* `up`: the blade's up vector, which corresponds to the normal of the geometry that the grass blade resides on at `v0`
* Orientation: the orientation of the grass blade's face
* Height: the height of the grass blade
* Width: the width of the grass blade's face
* Stiffness coefficient: the stiffness of our grass blade, which will affect the force computations on our blade

We can pack all this data into four `vec4`s, such that `v0.w` holds orientation, `v1.w` holds height, `v2.w` holds width, and `up.w` holds the stiffness coefficient.

### Simulating Forces

We separate our rendering pipeline into two passes: first pass to render current form of grass blades and second pass to compute updated paramters for the next frame. Physical force simulation is performed in the second pass as a compute shader. This compute shader pass alters the control points of each grass blade according to forces being applied on them.

#### Gravity

Given a gravity direction, `D.xyz`, and the magnitude of acceleration, `D.w`, we can compute the environmental gravity in our scene as `gE = normalize(D.xyz) * D.w`.

We then determine the contribution of the gravity with respect to the front facing direction of the blade, `f`, as a term called the "front gravity". Front gravity is computed as `gF = (1/4) * ||gE|| * f`.

We can then determine the total gravity on the grass blade as `g = gE + gF`.

#### Recovery

Recovery corresponds to the counter-force that brings our grass blade back into equilibrium. This is derived in the paper using Hooke's law. In order to determine the recovery force, we need to compare the current position of `v2` to its original position before simulation started, `iv2`. At the beginning of our simulation, `v1` and `v2` are initialized to be a distance of the blade height along the `up` vector.

Once we have `iv2`, we can compute the recovery forces as `r = (iv2 - v2) * stiffness`.

#### Wind

![](writeup/wind_dir.png)

We represent wind as an analytic function `w_i(v_0)` that outputs direction and strength of the wind influence at the position of a blade of grass. The analytic functions can be modeled heuristically using multiple sine and cosine functions with different frequencies. This can simulate wind coming from some direction or a specific source, like a helicopter or a fan.

The strength by which our blades are affected by wind should also be affected by the alignment of the grass blades to the direction of wind. That is, a grass blade facing perpendicular to the wind direction should be affected more strongly by the wind. Similarly, a grass blade standing more straight up (so greater surface area exposed) should be affected more strongly by the wind as well. These two ideas are captured by the following equations where `f_d` is the directional alignment and `f_r(h)` represents the straightnes of the blade with respect to the up vector.

![](writeup/wind_eq.png)

Once we have a wind direction and a wind alignment term, we can compute total wind force (`w`) as `w_i(v_0) * windAlignment`.

### Culling tests

Although we need to simulate forces on every grass blade at every frame, there are many blades that we won't need to render due to a variety of reasons. Here are some heuristics we implement in this project to cull blades that won't contribute positively to a given frame.

#### Orientation culling

#### View-frustum culling

#### Distance culling

### Performance

* Tested on: Windows 10, AMD Ryzen 5 5600X 6-Core Processor @ 3.70GHz, 32GB RAM, NVIDIA GeForce RTX 3070 Ti (Personal Computer)

## Credits

- [Responsive Real-Time Grass Rendering for General 3D Scenes](https://www.cg.tuwien.ac.at/research/publications/2017/JAHRMANN-2017-RRTG/JAHRMANN-2017-RRTG-draft.pdf)