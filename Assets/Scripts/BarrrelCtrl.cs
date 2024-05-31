using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class BarrrelCtrl : MonoBehaviour
{
    public GameObject expEffect;

    public Texture[] texture;

    private new MeshRenderer renderer;

    private Transform tr;
    private Rigidbody rb;
    private int hitCount = 0;
    public float radius = 10.0f;
    void Start()
    {
        tr = GetComponent<Transform>();
        rb = GetComponent<Rigidbody>();
        renderer = GetComponentInChildren<MeshRenderer>();
        // 암기
        int idx = Random.Range(0, texture.Length);
        renderer.material.mainTexture = texture[idx];
    }

    // Update is called once per frame
    void Update()
    {
        
    }
    void ExpBarrel()
    {
        GameObject exp = Instantiate(expEffect, tr.position, Quaternion.identity);
        Destroy(exp, 5.0f);
        //rb.mass = 1.0f;
        //rb.AddForce(Vector3.up * 1500.0f);
        IndirectDamege(tr.position); // 함수 외우기 physic 등등
        Destroy(gameObject ,3.0f);
    }
    void IndirectDamege(Vector3 pos)
    {
        Collider[] colls = Physics.OverlapSphere(pos, radius, 1 << 7); // 드럼통을 추출
        foreach(var coll in colls)
        {
            rb = coll.GetComponent<Rigidbody>();
            rb.mass = 1.0f;
            rb.constraints = RigidbodyConstraints.None;
            rb.AddExplosionForce(1500.0f, pos, radius, 1200.0f);
        }
    }
    private void OnCollisionEnter(Collision collision)
    {
        if(collision.collider.tag == "BULLET")
        {
            if(++hitCount == 3)
            {
                ExpBarrel();
            }
        }
    }
}
