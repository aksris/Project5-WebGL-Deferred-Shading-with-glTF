#version 100
precision highp float;
precision highp int;

#define NUM_GBUFFERS 3
// #extension GL_OES_standard_derivatives : enable

uniform vec3 u_lightCol;
uniform vec3 u_lightPos;
uniform float u_lightRad;
uniform vec3 u_viewDir;
uniform sampler2D u_gbufs[NUM_GBUFFERS];
uniform sampler2D u_depth;
uniform int u_toon;

varying vec2 v_uv;

// const vec3 ambientColor = vec3(0.1, 0.1, 0.1);
// const vec3 diffuseColor = vec3(0.5, 0.5, 0.5);
// const vec3 specColor = vec3(1.0, 1.0, 1.0);
// const float shininess = 16.0;
// const float screenGamma = 2.2; // Assume the monitor is calibrated to the sRGB color space

// vec3 applyNormalMap(vec3 geomnor, vec3 normap) {
//     normap = normap * 2.0 - 1.0;
//     vec3 up = normalize(vec3(0.001, 1, 0.001));
//     vec3 surftan = normalize(cross(geomnor, up));
//     vec3 surfbinor = cross(geomnor, surftan);
//     return normap.y * surftan + normap.x * surfbinor + normap.z * geomnor;
// }

void main() {
    vec4 gb0 = texture2D(u_gbufs[0], v_uv);
    vec4 gb1 = texture2D(u_gbufs[1], v_uv);
    vec4 gb2 = texture2D(u_gbufs[2], v_uv);
    // vec4 gb3 = texture2D(u_gbufs[3], v_uv);
    float depth = texture2D(u_depth, v_uv).x;
    // TODO: Extract needed properties from the g-buffers into local variables
    vec3 pos = gb0.xyz;     // World-space position
    // vec3 geomnor = gb1.xyz;  // Normals of the geometry as defined, without normal mapping
    vec3 nor = normalize(gb1.xyz);
    vec3 colmap = gb2.rgb;  // The color map - unlit "albedo" (surface color)
    // vec3 normap = gb3.xyz;  // The raw normal map (normals relative to the surface they're on)
    // vec3 nor = applyNormalMap (geomnor, normap);     // The true normals as we want to light them - with the normal map applied to the geometry normals (applyNormalMap above)

    // If nothing was rendered to this pixel, set alpha to 0 so that the
    // postprocessing step can render the sky color.
    // if (depth == 1.0) {
    //     gl_FragColor = vec4(0, 0, 0, 0);
    //     return;
    // }

    float lightDistance = distance(u_lightPos, pos);
    if (lightDistance  > u_lightRad) {
        return;
    }
    float edgeDetection = 1.0;

    vec3 lightDir = normalize(u_lightPos - pos);
    float lambertian = clamp(dot(lightDir, normalize(nor)), 0.0, 1.0);
    vec3 viewDir = normalize(u_viewDir - pos);
     // this is blinn phong
    vec3 halfDir = normalize(lightDir + viewDir);
    float specAngle = max(dot(halfDir, nor), 0.0);
    float specular = float(lambertian > 0.0) * pow(specAngle, 16.0);
    float falloff = clamp(1.0 - (lightDistance * lightDistance)/(u_lightRad * u_lightRad), 0.0, 1.0);
     if(u_toon == 1) {
        /* Reference: http://prideout.net/blog/?p=22 */
        // float cutoff = 3.0;
        // lambertian = ceil(lambertian * cutoff) / cutoff;
        // specular = ceil(specular * cutoff) / cutoff;
        // falloff = ceil(falloff * cutoff) / cutoff;
        const float A = 0.1;
        const float B = 0.3;
        const float C = 0.6;
        const float D = 1.0;

        if (lambertian < A) lambertian = 0.1;
        else if (lambertian < B) lambertian = 0.35;
        else if (lambertian < C) lambertian = 0.7;
        else lambertian = D;
        specular = step(0.5, specular);
        edgeDetection = (dot(viewDir, nor) > 0.4) ? 1.0 : 0.0;
    }

    gl_FragColor = vec4(
        (colmap * lambertian +
        specular * vec3(1.0)) * u_lightCol * falloff * edgeDetection
        , 1);
}
