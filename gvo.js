const myStoredStepCounter = localStorage.getItem('myStepCounter');
let myStepCounter = JSON.parse(myStoredStepCounter);
console.log('myStepCounter = ' + myStepCounter);
const myStoredDataHandle = localStorage.getItem('myDataHandle');
const myDataHandle = JSON.parse(myStoredDataHandle);
//let blindSpotX = myDataHandle[1][0];
blindSpotX = 400; //for development
//myDataHandle[0][2] = -1;//for development
myStepCounter = 1; //for development 
console.log('blindSpotX at load = ' + blindSpotX); 

const gvoStartDeley = 2000; //delay before 1st stimulus
const acceptedResponseDeley = 1000; //response delayed after stimulus is shown must be < stimulusInterval - stimulusIntervalVariation
const repGvo = 1; //not yet implemented
const stimulusDuration = 200; //duration of a stimulus, default 200
const stimulusInterval = 200; //default 1500, base interval between consecutive stimuli
const stimulusIntervalVariation = 200; //default 200, random deviation from the set interval
const stimulusSize = 3; //goldmann size 1-5, default 3 = 0.43deg diameter, approximated at fixation point. 
let myParsedMatrix;
let indices = []; 
let myRandomSeq = [];
let keyPressLog = [];

//test locations in degrees, NB y-axis positive direction is up
let testLocationDegrees = [
    [0, 0],
    [10, 12],
    [-10, -12],
    [10, -12],
    [-10, 12],
    [2, 2],
    [-2, -2],
    [2, -2],
    [-2, 2],
    [18, 4],
    [-18, -8],
    [18, -8],
    [-18, 4],
    [6, 2],
    [-6, -2],
    [6, -2],
    [-6, 2],
    [15, -2],
    [-15, -2],
    [2, 8],
    [-2, -8],
    [2, -8],
    [-2, 8],
    [12, 4],
    [-12, 4],
];


//Declare myGvoMatrix, where all data will be stored, later parsed by gvoResult page via local storage
//myGvoMatrix elements: [response counter, position top %, position left %, timestamp of appearance in rep 1, rep 2, ...]
//const myGvoMatrix = Array.from({length: numRows}, () => Array.from({ length: numColumns }, () => []));

const myGvoMatrix = Array.from({length: 25}, () => []);


//function to shuffel array
function shuffle(array) {
    for (let i = array.length - 1; i > 0; i--) {
        const j = Math.floor(Math.random() * (i + 1));
        [array[i], array[j]] = [array[j], array[i]];
    }
    return array;
}
  
//function to show and hide stimulus
function showStimulus(callback){
    document.getElementById('stimulus').style.display = 'block';
    console.log(Date.now());
    setTimeout(() => {
        callback();
    }, stimulusDuration);
}
function hideStimulus(){
    document.getElementById('stimulus').style.display = 'none';
    //console.log(Date.now())
}

//beep for key presses
const beep = document.getElementById("beep");
function playAudio() {
  beep.play();
}

//function to set positions of stimuli based on number of screen sections
function setPosition(top, left) {
    document.getElementById('stimulus').style.top = top;
    document.getElementById('stimulus').style.left = left;
}

//set window to be maximized
/*
window.onload = function() {
    window.moveTo(0, 0);
    window.resizeTo(screen.availWidth, screen.availHeight);
};
*/

//generate an array myRandomSeq containing random sequence of indices of myGvoMatrix, skipping center index
for (let i = 0; i < 25; i++){
    indices.push(i);
}

function getTanDeg(deg) {
    const rad = (deg * Math.PI) / 180;
    return Math.tan(rad);
}
let userDistance = blindSpotX / getTanDeg(15);

//set position of stimulus, push into indices. 
for (let i = 0; i < 25; i++){
    myGvoMatrix[i][0]=0;
    myGvoMatrix[i][1]= String(Math.round((0.5 - userDistance * getTanDeg(testLocationDegrees[i][1])/screen.availHeight) * 100)) + "%"; //y-axis positive value is up, so subtract from mid
    myGvoMatrix[i][2]= String(Math.round((0.5 + userDistance * getTanDeg(testLocationDegrees[i][0])/screen.availWidth) * 100)) + "%";
}

console.log(myGvoMatrix);

//randomize
myRandomSeq = shuffle(indices);

function setStimulusSize(){
    //take userDistance, multiply by 2 * tan(deg stimulus radius)
    let stimulusDiameterDeg = 0.43 * Math.pow(2, stimulusSize - 3);
    let stimulusDiameterPx = userDistance * getTanDeg(stimulusDiameterDeg / 2) * 2;
    document.getElementById("fixationPoint").style.width = String(stimulusDiameterPx) + 'px';
    document.getElementById("fixationPoint").style.height = String(stimulusDiameterPx) + 'px';
    document.getElementById("stimulus").style.width = String(stimulusDiameterPx) + 'px';
    document.getElementById("stimulus").style.height = String(stimulusDiameterPx) + 'px';
}
setStimulusSize();

//function for running the gvo
function runGvo() {
    let myRandomInterval; 
    //showing stimulus in random order stored in myRandomSeq
    for (let i = 0; i < myRandomSeq.length + 1; i++){
        myRandomInterval = Math.floor((Math.random()*2 - 1) * stimulusIntervalVariation);
        if (i === myRandomSeq.length){
            //at the end of run: show results button, generate results, local storage
            setTimeout(function(){
                document.removeEventListener("keydown", keyDownEvent);
                //document.removeEventListener("click", keyDownEvent);
                document.getElementById('showResults').style.display = 'block';
                //setPosition(myGvoMatrix[numRows][4][1],myGvoMatrix[numRows][4][2]); //for development, show blindspot at the end
                //document.getElementById('stimulus').style.display = 'block';
                generateResults();
                myDataHandle[myStepCounter][1] = myGvoMatrix;
                localStorage.setItem('myDataHandle', JSON.stringify(myDataHandle));
                console.log(myDataHandle);
                //myStepCounter +=1;
                //console.log('myStepCounter + 1 = ' + myStepCounter);
                //localStorage.setItem('myStepCounter', JSON.stringify(myStepCounter));
            }, (i+1) * stimulusInterval);
        } else {
            //set position of each stimulus, show it, store the timestamp of each stimulus in myGvoMatrix
            setTimeout(function(){
                setPosition(myGvoMatrix[myRandomSeq[i]][1],myGvoMatrix[myRandomSeq[i]][2]);
                myGvoMatrix[myRandomSeq[i]][3] = Date.now();
                showStimulus(hideStimulus);
            }, (i+1) * stimulusInterval + myRandomInterval);
        }
    }      
}



function delayedRunGvo() {
    setTimeout(() => {
        runGvo();
    }, gvoStartDeley);
}

delayedRunGvo();
    
//log timestamp of all key presses in an array
document.addEventListener("keydown", keyDownEvent);
//document.addEventListener("click", keyDownEvent);
function keyDownEvent(event){
    event.preventDefault();
    if (event.code === 'Space' || event.key === ' ') {
        playAudio();
        keyPressLog.push(Date.now());
    }
}

//register a +1 if at least 1 key press is logged within acceptedResponseDeley after the stimulus is shown
function generateResults(){
    for (i = 0; i < myRandomSeq.length; i++){
        for (k=0; k < keyPressLog.length; k++){
            if (keyPressLog[k] - myGvoMatrix[i][3] > 0 && keyPressLog[k] - myGvoMatrix[i][3] <= acceptedResponseDeley){
                myGvoMatrix[i][0] ++;
                break;
            }
        }
    }
}


