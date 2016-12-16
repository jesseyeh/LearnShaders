using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class NewBehaviourScript : MonoBehaviour {

    [SerializeField] ComputeShader shader;

    struct VectorMatrixPair {
        public Vector3 point;
        public Matrix4x4 matrix;
    }

	// Use this for initialization
	void Start () {
		
	}
	
	// Update is called once per frame
	void Update () {
		
	}

    void RunShader() {
        VectorMatrixPair[] data = new VectorMatrixPair[5];
        VectorMatrixPair[] output = new VectorMatrixPair[data.Length];

        // 3 float values in Vector, 16 float values in Matrix4x4, float are 4 bytes in size
        ComputeBuffer buffer = new ComputeBuffer(data.Length, (3+16)*4);
        int kernel = shader.FindKernel("Multiply");
        shader.SetBuffer(kernel, "dataBuffer", buffer);
        shader.Dispatch(kernel, data.Length, 1, 1);

        // transfer structured buffer from GPU mem back to CPU mem
        buffer.GetData(output);
    }

    /*
    void RunShader() {
        // the function to call in our compute shader
        int kernelHandle = shader.FindKernel("CSMain");

        RenderTexture tex = new RenderTexture(256, 256, 24);
        tex.enableRandomWrite = true; // gives compute shader access to write to the texture
        tex.Create();

        // allows us to move data we want to work with from CPU mem to GPU mem
        shader.SetTexture(kernelHandle, "Result", tex);
        // specifies the number of thread groups we want to spawn
        // in this case, 32*32 thread groups, each with 64 threads = 65536 total threads
        // render texture is 256x256, so 1 thread per pixel on the render texture
        // kernel function can only operate on 1 pixel per call
        shader.Dispatch(kernelHandle, 256/8, 256/8, 1);
    }
    */
}
