# worldly-ocr
[Status] 

# worldly-ocr
[status]
 
## About
The goal is to build a next generation of **OCR technology**.  Eventually, it helps to target for a large-scale, open source, global language and culture data bank.
 
This package contains an **OCR engine** specifically for **Pashto, Persian, and Traditional Chinese**. Currently it consists of major components: segmentation, layout analysis and OCR. Its OCR function uses certain parts of latest Tesseract OCR (https:\\//github.com/tesseract-ocr/tesseract) for character recognition.
 
Many implementations of OCR software exist, both commercial and open source, but they do not produce useful results for Traditional Chinese, Pashto, and Persian literature. 90%+ accuracy rate is a threshold for OCR to be useful. Some of the most spectacular failures of OCR software are not a result of its inability to recognize characters, but are unable to perform accurate layout analysis by identifying text regions, images, and text direction.
 
The proposed advanced implementation will be a **next generation of OCR software capable of handling complex layouts**.

The project is currently funded by the National Endowment of Humanities (NEH) for $75,000 for the period of 2019. 

Marek Rychlik is the Principal Investigator. Yan Han and Dylan Murphy are the Co-PI. Other project staff include Raymundo Navarette, Dwight Nwaigwe, Sayyed Mohsen Vazirzade. 

## History
The current team started studying the OCR problem in Fall 2017. Marek approached Yan about the Afghan Digital Collection, the largest digital repository related to Afghanistan and related areas, at the University of Arizona Libraries. Yan Han and his colleague Atifa Rawan have been working with ACKU for the past 11 years on providing access and preservation of Afghanistan materials. To date, the Afghanistan Digital Collection provides preservation of and access to an extensive collection of Afghan related materials (1.7+ million pages) and 500k pageviews in usage since its first availability in 2010. 

In 2017, the project team started a regular seminar devoted to OCR with emphasis on these languages. We surveyed available OCR systems and most successful algorithms. It turns out that the best algorithm of today is based on Long-Short Memory (LSTM) recurrent neural network (RNN), and which is implemented in the two most accurate OCR systems when applied to Arabic: Kraken and Tesseract. We evaluated both systems for accuracy and studied the methodology of extending these systems to handle Pashto. 

We set up a Subversion repository of test data, code written in MATLAB, and a collection of relevant research papers. We investigated the theory of LSTM and discovered certain new RNNs which may be better for OCR than LSTM (to be further studied). We also added Traditional Chinese to our studies, a different writing system, in order to increase our understanding of common and distinct features of various writing systems. 

Our preliminary research suggests that current OCR has low accuracy especially on Traditional Chinese texts printed before the 1900s.We developed a new algorithm which in tests shows the ability to recognize several common Chinese characters in a 118 page document with very high accuracy (> 95%). A video used in the visualization of the search for a particular character ( ).

Furthermore, we discovered that current OCR systems trip up on the initial phase of processing, image segmentation, whose goal is to isolate characters by subdividing areas of the image occupied by different characters into regions.

2017 - , OCR seminars are held every Friday. Information is available at (http://alamos.math.arizona.edu/ocr/) 

2018, The research project was funded by the National Endowment for the Humanities (NEH) for the amount of $75,000. This Phase I we are focusing on creating prototype software for extracting complete and accurate full-text for Pashto and traditional Chinese languages. We have made good progress and would like to demonstrate the current research to you. 

2019, A new NEH grant was submitted for Phase II of this project. It will focus on scalability and new language (e.g. Persian) with the use of Natural Language Processing along with Machine Learning and Artificial Intelligence. 

## Installation


## Running 


## Support


## License
**NOTE**: This package depends on other packages that may be licensed under different open source licenses. 


## Dependencies


For the latest online version of the README.md see: 


 
# Examples of Traditional Chinese processing
 
[![Traditional Chinese OCR](http://img.youtube.com/vi/2VHX5HnZHaY/0.jpg)]( https://www.youtube.com/embed/2VHX5HnZHaY "Traditional Chinese OCR")
 
 
