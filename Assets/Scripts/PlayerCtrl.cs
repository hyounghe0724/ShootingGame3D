using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class PlayerCtrl : MonoBehaviour
{
    private Transform tr;
    private Animation anim;

    [Header("Bullet")]
    [SerializeField]
    private GameObject bullet;
    [Header("Fire Pos")]
    [SerializeField]
    private Transform firePos;

    private float h;
    private float v;
    private float r;
    private int moveSpeed = 10;
    private int rotSpeed = 100;
    private readonly float initHp = 100.0f;

    public float turnSpeed = 80.0f;

    public float currHp = 100.0f;
    public delegate void PlayerDieHandler();

    public static event PlayerDieHandler OnPlayerDie;
    /*void Start()
    {
        Cursor.visible = false;
        Cursor.lockState = CursorLockMode.Locked;
        tr = GetComponent<Transform>();
        anim = GetComponent<Animation>();
        anim.Play("Idle");

        turnSpeed = 0.0f;
        yield return new WaitForSeconds(0.3f);
        turnSpeed = 80.0f;
    }*/
    IEnumerator Start()
    {
        // 주기적으로 Start 함수 호출
        Cursor.visible = false;
        Cursor.lockState = CursorLockMode.Locked;
        tr = GetComponent<Transform>();
        anim = GetComponent<Animation>();
        anim.Play("Idle");

        turnSpeed = 0.0f;
        yield return new WaitForSeconds(0.3f);
        turnSpeed = 80.0f;
    }

    // Update is called once per frame
    void Update()
    {
        h = Input.GetAxis("Horizontal");
        v = Input.GetAxis("Vertical");
        r = Input.GetAxis("Mouse X");
        
        Vector3 moveDir = (Vector3.forward * v) + (Vector3.right * h);
        tr.Translate(moveDir.normalized * Time.deltaTime * moveSpeed, Space.Self);
        tr.Rotate(Vector3.up * Time.deltaTime * rotSpeed * Input.GetAxis("Mouse X")
       );
       
        // 애니매이션 블렌딩
        PlayerAnim(h, v);
       //ShootingPrefab();
    }
    void PlayerAnim(float h, float v)
    {
        if (v >= 0.1f) // forward
        {
            anim.CrossFade("RunF", 0.25f); // 블렌딩
        }
        else if (v <= -0.1f) // back
        {
            anim.CrossFade("RunB", 0.25f);
        }
        else if (h >= 0.1f)
        {
            anim.CrossFade("RunR", 0.25f);
        }
        else if (h <= -0.1f)
        {
            anim.CrossFade("RunL", 0.25f);
        }
        else
        {
            anim.CrossFade("Idle", 0.25f);
        }
    }

    void ShootingPrefab()
    {
        if (Input.GetMouseButtonDown(0))
        {
            Instantiate(bullet, firePos.position, firePos.rotation);
            Debug.Log("Shooting!");
        }
    }

    void PlayerDie()
    {
       /* GameObject[] monsters = GameObject.FindGameObjectsWithTag("MONSTER");
        foreach(GameObject monster in monsters)
        {
            // OnPlayerDie 함수 호출
            monster.SendMessage("OnPlayerDie", SendMessageOptions.DontRequireReceiver);
        }*/
        OnPlayerDie();
    }
    private void OnTriggerEnter(Collider other)
    {
        if (currHp >= 0.0f && other.CompareTag("PUNCH")){
            currHp -= 10.0f;
            Debug.Log($"Player hp = {currHp / initHp}");

            if(currHp <= 0.0f)
            {
                PlayerDie();
            }
        }
    }
}
