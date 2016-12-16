using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class MyComputeScript : MonoBehaviour {

    [SerializeField] ComputeShader shader;

    private int _Kernel;

	// Use this for initialization
	void Start () {
        _Kernel = shader.FindKernel(MyStrings.MFC.CSMain);
		RunShader();
	}
	
	// Update is called once per frame
	void Update () {
		
	}

    void RunShader() {
        Vector3[] array = new Vector3[15];

        ComputeBuffer buffer = new ComputeBuffer(array.Length, 12);
        buffer.SetData(array);

        shader.SetBuffer(_Kernel, MyStrings.MFC.Output, buffer);
        shader.Dispatch(_Kernel, array.Length, 1, 1);

        Vector3[] data = new Vector3[array.Length];
        buffer.GetData(data);
        buffer.Dispose();
    }

    /*
    void RunShader() {
        // int kernelIndex = shader.FindKernel("CSMain");

        RenderTexture tex = new RenderTexture(512, 512, 24);
        tex.enableRandomWrite = true; // allows the GPU to modify the data we send
        tex.Create();

        shader.SetTexture(_Kernel, MyStrings.MFC.Result, tex);
        shader.Dispatch(_Kernel, 512/8, 512/8, 1);
    }
    */
}
