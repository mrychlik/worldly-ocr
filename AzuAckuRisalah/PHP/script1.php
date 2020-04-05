#!/usr/bin/env php 
<?php
$json = '{
  "data": {
    "translations": [
      {
        "translatedText": "Contradictory intention is to be realistic but easily self-sufficient"
      }
    ]
  }
}';


$arr=json_decode($json);

# var_dump($arr);


print $arr->data->translations[0]->translatedText;
