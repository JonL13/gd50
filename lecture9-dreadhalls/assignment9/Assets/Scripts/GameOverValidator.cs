using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.SceneManagement;

public class GameOverValidator : MonoBehaviour
{
    public GameObject whisperSource;

    // Start is called before the first frame update
    void Start()
    {
        
    }

    // Update is called once per frame
    void Update()
    {
        if(gameObject.GetComponentInParent<Transform>().position.y < -10){           
            // AudioSource[] audioSources = Object.FindObjectsOfType<AudioSource>();
            // foreach(AudioSource audioSource in audioSources){
            //     audioSource.Pause();
            // }

            GameObject whisperSource = GameObject.Find("WhisperSource");
            Destroy(whisperSource);

            LevelNumber.levelNumber = 1;
            SceneManager.LoadScene("GameOver");
        }
    }
}
