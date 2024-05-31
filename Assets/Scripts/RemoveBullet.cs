using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class RemoveBullet : MonoBehaviour
{
    public GameObject sparkEffect;

    
    private void OnCollisionEnter(Collision collision)
    {
        if (collision.gameObject.CompareTag("BULLET")){
            ContactPoint cp = collision.GetContact(0);
            Quaternion rot = Quaternion.LookRotation(-cp.normal);
            GameObject spark = Instantiate(sparkEffect, cp.point, rot);
            Destroy(collision.gameObject);
            Destroy(spark, 0.5f);
        }        
    }
}
