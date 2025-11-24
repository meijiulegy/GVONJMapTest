function testFunction() {
  alert("how do i do this again?");
}

//localStorage.removeItem('myDataHandle');
let myStepCounter = 0;
let blindSpotX = screen.availWidth/4;
console.log(window.innerWidth);
console.log(window.innerHeight);

const myDataHandle = Array.from({length: 3}, () => Array.from({ length: 6}, () => []));
console.log('myStepCounter = ' + myStepCounter);
console.log('myDataHandle = ' + myDataHandle);

document.addEventListener("DOMContentLoaded", function () {
  localStorage.removeItem('myDataHandle');
  const nameInput = document.getElementById("name");
  const dobInput = document.getElementById("dob");
  const genderSelect = document.getElementById("gender");
  const submitButton = document.getElementById("userIDSubmit");
  const userIDForm = document.getElementById('userIDForm');

  function checkForm() {
    if (nameInput.value.trim() && dobInput.value && genderSelect.value) {
      submitButton.disabled = false;
    } else {
      submitButton.disabled = true;
    }
  }

  nameInput.addEventListener("input", checkForm);
  dobInput.addEventListener("input", checkForm);
  genderSelect.addEventListener("change", checkForm);

  userIDForm.addEventListener('submit', function(event) {
    event.preventDefault(); 
    const name = nameInput.value;
    const gender = document.getElementById('gender').value;
    const dob = document.getElementById('dob').value;
    myDataHandle[0][5] = [name, gender, dob];
    console.log(myDataHandle[0][5]);
    document.getElementById('userIDForm').style.display = 'none';
    document.getElementById('instructionContainer').style.display = 'block';
  });
});

document.addEventListener('DOMContentLoaded', (event) => {
  const calibrationButton = document.getElementById("calibrationButton");
  let testEyeRad = document.querySelectorAll("input[name='testEye']");
  let testEye;

  function openNewWindow() {  
      window.open(
          'calibration.html',
          'newwindow',
          `width=${screen.availWidth},height=${screen.availHeight},scrollbars=no,toolbar=no,location=no,directories=no,status=no,menubar=no`
      );
  }
  
  function buttonClicked(event) {
      //event.preventDefault();
      registerTestEye(); //also registers default blindspot location and calibration method sequence
      openNewWindow();
  }

  testEyeRad.forEach(rb => rb.addEventListener("change", function(){
      calibrationButton.disabled = false;
      testEye = document.querySelector("input[name='testEye']:checked").value;
      console.log('testEye = ' + testEye);
  }));

  //also registers default blindspot location and calibration method sequence
  function registerTestEye(){
      myDataHandle[0][0] = blindSpotX;
      myDataHandle[0][2] = parseInt(testEye);
      if (myDataHandle[0][2] == -1) {
        myDataHandle[1][0] = 0;
        myDataHandle[2][0] = 1;
      }else if(myDataHandle[0][2] == 1) {
        myDataHandle[1][0] = 1;
        myDataHandle[2][0] = 0;
      }else{
        myDataHandle[1][0] = 1;
        myDataHandle[2][0] = 1;
      }
      localStorage.setItem('myStepCounter', JSON.stringify(myStepCounter));
      localStorage.setItem('blindSpotX', JSON.stringify(blindSpotX));
      localStorage.removeItem('myDataHandle');
      localStorage.setItem('myDataHandle', JSON.stringify(myDataHandle));
  }

  //calibrationButton.style.display = 'none';
  calibrationButton.addEventListener('click', buttonClicked);
});
