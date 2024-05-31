using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class BulletCTR : MonoBehaviour
{
    public float force = 1500.0f;
    private Rigidbody rbody;

  
    // Start is called before the first frame update
    void Start()
    {
        rbody = GetComponent<Rigidbody>();
        rbody.AddForce(transform.forward * force);
    }

    // Update is called once per frame
    void Update()
    {
        
    }

   
}
