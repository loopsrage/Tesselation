using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class CameraCircle : MonoBehaviour
{
    public float Speed;
    // Use this for initialization
    void Start()
    {
        Speed = 80;
    }

    // Update is called once per frame
    void Update()
    {
        if (transform.parent != null)
        {
            transform.RotateAround(new Vector3(transform.parent.position.x, transform.parent.position.y, transform.parent.position.z), Vector3.down, Speed * Time.deltaTime);

        }
    }
}
