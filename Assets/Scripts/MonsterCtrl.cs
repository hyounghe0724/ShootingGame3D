using System.Collections;
using System.Collections.Generic;
using Unity.VisualScripting;
using UnityEngine;
using UnityEngine.AI;
using UnityEngine.Tilemaps;

public class MonsterCtrl : MonoBehaviour
{
    public enum State
    {
        IDLE,
        PATROL,
        TRACE,
        ATTACK,
        DIE
    }

    public State state = State.IDLE;
    public float traceDist = 10.0f;
    public float attackDist = 4.0f;
    public bool isDie = false;

    private Transform monsterTr;
    private Transform playerTr;
    private NavMeshAgent nvAgent;
    private Animator anim;

    public GameObject bloodEffect; // ¹Ù´Ú
    public GameObject bloodDecal; // ¸ö
    // Start is called before the first frame update
    private int hp = 100;

    private readonly int hashTrace = Animator.StringToHash("isTrace");
    private readonly int hashAttack = Animator.StringToHash("isAttack");
    private readonly int hashHit = Animator.StringToHash("Hit");
    private readonly int hashPlayerDie = Animator.StringToHash("PlayerDie");
    private readonly int hashSpeed = Animator.StringToHash("Speed");
    private readonly int hashDie = Animator.StringToHash("Die");
   
    void Start()
    {
        monsterTr = this.gameObject.GetComponent<Transform>();
        playerTr = GameObject.FindWithTag("Player").GetComponent<Transform>();
        nvAgent = this.gameObject.GetComponent<NavMeshAgent>();
        anim = this.GetComponent<Animator>();
        // bloodEffect = Resource.Load<GameObject>("BloodSprayEffect");
        nvAgent.destination = playerTr.position;
        StartCoroutine(CheckMonsterState());
        StartCoroutine(MonsterAction());
    }
    private void OnEnable()
    {
        PlayerCtrl.OnPlayerDie += this.OnPlayerDie;
    }
    private void OnDisable()
    {
        PlayerCtrl.OnPlayerDie -= this.OnPlayerDie;
    }
    // Update is called once per frame
    void Update()
    {
    }
    IEnumerator CheckMonsterState()
    {
        while (!isDie)
        {
            float distance = Vector3.Distance(playerTr.position, monsterTr.position);
            if (distance <= attackDist && state !=State.DIE)
            {
                state = State.ATTACK;
            }
            else if (distance <= traceDist && state != State.DIE)
            {
                state = State.TRACE;
            }
            else if(State.DIE == state)
            {
                yield break;
            }
            else
            {
                state = State.IDLE;
            }
            yield return new WaitForSeconds(0.3f);
        }
    }

    IEnumerator MonsterAction()
    {
        while (!isDie)
        {
            switch (state)
            {
                case State.IDLE:
                    nvAgent.isStopped = true;
                    anim.SetBool("isTrace", false);
                    break;
                case State.TRACE:
                    nvAgent.destination = playerTr.position;
                    nvAgent.isStopped = false;
                    anim.SetBool("isTrace", true);
                    anim.SetBool("isAttack", false);
                    break;
                case State.ATTACK:
                    anim.SetBool("isAttack", true);
                    break;
                case State.DIE:
                    Debug.Log("die");
                    isDie = true;
                    nvAgent.isStopped = true;
                    anim.SetBool("isTrace", false);
                    anim.SetBool("isAttack", false);
                    anim.SetTrigger(hashDie);
                    GetComponent<CapsuleCollider>().enabled = false;
                    break;
            }
            yield return new WaitForSeconds(0.3f);
        }
    }
    private void OnDrawGizmos()
    {
        if (state == State.TRACE)
        {
            Gizmos.color = Color.blue;
            Gizmos.DrawWireSphere(transform.position, traceDist);
        }
        if (state == State.ATTACK)
        {
            Gizmos.color = Color.red;
            Gizmos.DrawWireSphere(transform.position, attackDist);
        }
    }
    private void ShowBloodEffect(Vector3 pos, Quaternion rot)
    {

    }
    private void CreateBloodDecal(Vector3 pos)
    {
        Vector3 decalPos = monsterTr.position + (Vector3.up * 0.05f);
        GameObject blood1 = Instantiate(bloodDecal, decalPos, Quaternion.identity);
        Quaternion decalRot = Quaternion.Euler(90, 0, Random.Range(0, 360));
        float scale = Random.Range(1.5f, 3.5f);
        blood1.transform.localScale = Vector3.one * scale;
        blood1.transform.rotation = decalRot;
        Destroy(blood1, 5.0f);
    }
    private void OnCollisionEnter(Collision collision)
    {
        if (collision.gameObject.CompareTag("BULLET"))
        {
            
            Destroy(collision.gameObject);
            anim.SetTrigger(hashHit);
            Vector3 pos = collision.GetContact(0).point;
            // ¹ý¼±
            Quaternion rot = Quaternion.LookRotation(-collision.GetContact(0).normal);
            // ShowBloodEffect(pos, rot);

            CreateBloodDecal(pos);
            hp -= 10;
            if (hp <= 0)
            {
                state = State.DIE;
            }
        }
    }
    public void OnPlayerDie()
    {
        StopAllCoroutines();
        nvAgent.isStopped = true;
        anim.SetFloat(hashSpeed, Random.Range(0.8f, 1.2f));
        anim.SetTrigger(hashPlayerDie);
    }

}