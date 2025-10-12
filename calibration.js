const myStoredStepCounter = localStorage.getItem('myStepCounter');
let myStepCounter = JSON.parse(myStoredStepCounter);

let blindSpotX;
const myStoredDataHandle = localStorage.getItem('myDataHandle');
const myDataHandle = JSON.parse(myStoredDataHandle);

function openNewWindow() {  
    window.open(
        'gvo.html',
        'newwindow',
        `width=${screen.availWidth},height=${screen.availHeight},scrollbars=no,toolbar=no,location=no,directories=no,status=no,menubar=no`
    );
}

document.addEventListener('DOMContentLoaded', (event) => {
    const startGVOButton = document.getElementById("startGVO");
    const readyCheckbox = document.getElementById("ready");
    if (myDataHandle[0][2] == -1) {
        document.getElementById("chosenEye").innerHTML = 'When ready, cover your right eye, <strong>tick the "ready" checkbox and then press spacebar</strong> to start the test.';
    }else if(myDataHandle[0][2] == 1) {
        document.getElementById("chosenEye").innerHTML = 'When ready, cover your left eye, <strong>tick the "ready" checkbox and then press spacebar</strong> to start the test.';
    }else{
        document.getElementById("chosenEye").innerHTML = 'When ready, cover the eye that is not being tested, <strong>tick the "ready" checkbox and then press spacebar</strong> to start the test.';
    }

    document.getElementById('lineDiv').style.height = 0.2*window.innerWidth + 'px'
    document.getElementById('doubleArrow').style.width = 0.75*window.innerWidth + 'px';
    blindSpotX = Math.floor(0.75*0.268*window.innerWidth);
    myDataHandle[1][0] = blindSpotX;
    myDataHandle[2][0] = blindSpotX;
    localStorage.setItem('myDataHandle', JSON.stringify(myDataHandle));
    console.log(myDataHandle);
    console.log('blindSpotX = ' + blindSpotX);
    
    function buttonClicked(event) {
        //event.preventDefault();
        openNewWindow();
    }
    
    startGVOButton.style.display = 'none';
    startGVOButton.addEventListener('click', buttonClicked);
    document.addEventListener('keydown', function(event) {
        event.preventDefault();
        if (readyCheckbox.checked && (event.code === 'Space' || event.key === ' ')) {
            console.log('spacebar pressed');
            event.preventDefault();
            buttonClicked();
        }
    });
});