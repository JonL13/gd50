using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

public class LevelNumber : MonoBehaviour
{
    // Start is called before the first frame update
    public static int levelNumber = 1; 

    void Start()
    {
        
    }

    // Update is called once per frame
    void Update()
    {
        Text text = gameObject.GetComponentInParent<Text>();
        text.text = "Level: " + levelNumber;
    }
}
