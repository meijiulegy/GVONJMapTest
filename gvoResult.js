
 //parse stored data
const myStoredDataHandle = localStorage.getItem('myDataHandle');
const myDataHandle = JSON.parse(myStoredDataHandle);
console.log(myDataHandle);

const myStoredStepCounter = localStorage.getItem('myStepCounter');
let myStepCounter = JSON.parse(myStoredStepCounter);
myStepCounter = 1; //for developement

const resultCircleDiameter = "10px";
const resultDiagramWidth = 600;
let resultDiagramHeight = resultDiagramWidth * window.innerHeight/window.innerWidth; //change to = resultDiagramWidth for a square diagram
let buttonToShow;
let nextButton = document.getElementById("nextButton");
if (myStepCounter == 0){
  nextButton.disabled = false;
}

if (myStepCounter == 0) {
  document.getElementById('userScoreContainer').style.display = 'none';
}


if (myStoredDataHandle) {
  myParsedMatrix = myDataHandle[myStepCounter][1];
//  numRows = myDataHandle[0][3];
//  numColumns = myDataHandle[0][4];
  console.log(myParsedMatrix); 
} else {
  console.log("No GVO data found. You need to do the GVO first. See /gvo.html"); 
}

//devide the result diagram, then color the sections
const resultDiagram = document.getElementById('resultDiagram');
resultDiagram.style.width = resultDiagramWidth + 'px';
resultDiagram.style.height = resultDiagramHeight + 'px';

function showResults() {
  //const sectionWidth = resultDiagram.offsetWidth / numColumns; 
  //const sectionHeight = resultDiagram.offsetHeight / numRows;

  //draw axis labels using myParsedMatrix[17][1] as reference for 15 degrees eccentric
  const fiveDegreesX = (parseInt(myParsedMatrix[17][2]) - 50 ) / 3;
  console.log(fiveDegreesX);
  const fiveDegreesY = fiveDegreesX / (window.innerHeight/window.innerWidth);


  
  for (let i = -4; i <5; i++){
      let currentX;
      currentX = String(fiveDegreesX * i + 50) + "%"

      const lijntje = document.createElement('div');
      lijntje.classList.add('lijntje');
      lijntje.style.width = "2px";
      lijntje.style.height = "10px";
      lijntje.style.top = "100%";
      lijntje.style.left = currentX;
      lijntje.style.transform = "translate(0%, -100%)";
      resultDiagram.appendChild(lijntje);

      const span = document.createElement('span');
      span.textContent = String(i*5);
      span.className = 'axisNumber';
      span.style.top = "100%";
      span.style.left = currentX;
      span.style.transform = "translate(-50%, 50%)";
      resultDiagram.appendChild(span);
  }

  for (let i = -3; i <4; i++){
      let currentY;
      currentY = String(fiveDegreesY * i + 50) + "%"

      const lijntje = document.createElement('div');
      lijntje.classList.add('lijntje');
      lijntje.style.width = "10px";
      lijntje.style.height = "2px";
      lijntje.style.top = currentY;
      lijntje.style.left = "0%";
      //lijntje.style.transform = "translate(0%, -100%)";
      resultDiagram.appendChild(lijntje);

      const span = document.createElement('span');
      span.textContent = String(-i*5);
      span.className = 'axisNumber';
      span.style.top = currentY;
      span.style.left = "0%";
      span.style.transform = "translate(-150%, -50%)";
      resultDiagram.appendChild(span);
  }
  
  const xAxisLabel = document.createElement('span');
  xAxisLabel.textContent = "x (degree)";
  xAxisLabel.className = 'axisNumber';
  xAxisLabel.style.top = "100%";
  xAxisLabel.style.left = "50%";
  xAxisLabel.style.transform = "translate(-50%, 150%)";
  resultDiagram.appendChild(xAxisLabel);

  const yAxisLabel = document.createElement('span');
  yAxisLabel.textContent = "y (degree)";
  yAxisLabel.className = 'axisNumber';
  yAxisLabel.style.top = "50%";
  yAxisLabel.style.left = "0%";
  //yAxisLabel.style.display = 'inline-block';
  yAxisLabel.style.transform = "translate(-100%, -50%) rotate(-90deg)";
  //yAxisLabel.style.transformOrigin = 'left top';
  resultDiagram.appendChild(yAxisLabel);
  
  for (let i = 0; i < 25; i++) {
      if (myParsedMatrix[i][0] === -1) {
        continue;
      }
      const section = document.createElement('div');
      section.classList.add('section');
      section.style.width = resultCircleDiameter; //sectionWidth - 1 + 'px';
      section.style.height = resultCircleDiameter; //sectionHeight - 1 + 'px';
      section.style.borderRadius = "50%";
      //section.style.left = (j + 0.5) * sectionWidth - 2 + 'px';
      //section.style.top = (i + 0.5) * sectionHeight - 2 + 'px';
      section.style.top = myParsedMatrix[i][1];
      section.style.left = myParsedMatrix[i][2];
      section.style.transform = "translate(-50%, -50%)";
      
      //color missed section black
      if (myParsedMatrix[i][0] === 0) {
          section.style.backgroundColor = 'black';
      }

      /*
      //overwrite center section with yellow color
      if ((numRows % 2 == 1 && numColumns % 2 == 1) && (i == Math.floor(numRows/2) && j == Math.floor(numColumns/2))){
          section.style.backgroundColor = 'yellow';
      }
      */
    
      //bundle
      resultDiagram.appendChild(section);
  }

/*
  //add a center section with yellow color if even by even grid
  if (numRows % 2 == 0 || numColumns % 2 == 0) {
    const midPoint = document.createElement('div');
    midPoint.classList.add('section');
    midPoint.style.width = resultCircleDiameter; //sectionWidth - 1 + 'px';
    midPoint.style.height = resultCircleDiameter; //sectionHeight - 1 + 'px';
    midPoint.style.borderRadius = "50%";
    midPoint.style.left = resultDiagram.offsetWidth / 2 + 'px';
    midPoint.style.top = resultDiagram.offsetHeight / 2 + 'px';
    midPoint.style.transform = "translate(-50%, -50%)";
    midPoint.style.backgroundColor = 'yellow';
    resultDiagram.appendChild(midPoint);
  }
*/
}

function openNewWindow() { 

  window.open(
      'endInstructions.html',
      'newwindow',
      `width=${screen.availWidth},height=${screen.availHeight},scrollbars=no,toolbar=no,location=no,directories=no,status=no,menubar=no`
  );
}

/*
let methodSeq = myDataHandle[1][3];
let testCompleted = methodSeq.indexOf(myStepCounter) + 1;
if (testCompleted == 4) {
  nextButton.textContent = 'Next';
}
  */

showResults();
nextButton.disabled = false;
nextButton.addEventListener('click', openNewWindow)
localStorage.removeItem('myGvoMatrix');