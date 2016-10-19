using UnityEngine;
using System.Collections;

public class BounceTransform : MonoBehaviour {

	public float m_Height = 1f;
	public float m_Speed = 1f;

	private Vector3 m_InitialPosition;

	private void Start () {
		m_InitialPosition = transform.position;
	}

	private void Update ()
	{
		float bounce = Mathf.Abs( Mathf.Sin( Time.time * m_Speed * Mathf.PI ) * 0.5f + 0.5f );
		transform.position = m_InitialPosition + Vector3.up * bounce * m_Height;
	}
}
