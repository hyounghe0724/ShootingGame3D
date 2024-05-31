using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class FollowCam : MonoBehaviour
{
    public Transform targetTr;
    private Transform camTr;

    [Range(2.0f, 20.0f)] public float distance = 5.0f;
    [Range(0.0f, 10.0f)] public float height = 2.0f;
    public float dampling = 10.0f;
    private Vector3 velcity = new Vector3(5,1,5);

    private float targetOffset = 2.0f;
    void Start()
    {
        camTr = GetComponent<Transform>();
      
    }

  
    // Update is called once per frame
    void LateUpdate()
    {
        Vector3 pos = targetTr.position
                        + (-targetTr.forward * distance)
                        + (Vector3.up * height);
        // 방법 2
        camTr.position = Vector3.Slerp(camTr.position, pos, Time.deltaTime * dampling); // Lerp와 Slerp의 차이 개념 확립
        camTr.LookAt(targetTr.position + (targetTr.up * targetOffset));
        // 방법 3
        /*camTr.position = Vector3.SmoothDamp(camTr.position, targetTr.position, ref velcity, dampling);
        camTr.LookAt(targetTr.position);*/
    }

   
}
