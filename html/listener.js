function blink(id) {
	if (active === false) {
	var f = document.getElementById(id);
	setTimeout(function() {
	   f.style.display = (f.style.display == 'none' ? '' : 'none');
	}, 500);
	setTimeout(function() {
	   f.style.display = (f.style.display == 'none' ? '' : 'none');
	}, 1000);
	}
}

var display = false
var active = false

$(function(){
	window.onload = (e) => {
        /* 'links' the js with the Nui message from main.lua */
		window.addEventListener('message', (event) => {
            //document.querySelector("#logo").innerHTML = " "
			var item = event.data;
			if (item !== undefined && item.type === "waterLevel") {
				if (item.tankStatus >= 100) {
					$("#Full").show();
					$("#ThreeFour").hide();
					$("#OneHalf").hide();
					$("#OneFour").hide();
					$("#Empty").hide();
				} else if (item.tankStatus >= 75) {
					$("#Full").hide();
					$("#ThreeFour").show();
				} else if (item.tankStatus >= 50) {
					$("#ThreeFour").hide();
					$("#OneHalf").show();
				} else if (item.tankStatus >= 25) {
					$("#OneHalf").hide();
					$("#OneFour").show();
				} else if (item.tankStatus >= 0) {
					$("#OneFour").hide();
					$("#Empty").show();
				}else {
					$("#Full").hide();
					$("#ThreeFour").hide();
					$("#OneHalf").hide();
					$("#OneFour").hide();
					$("#Empty").show();
				}
			} else if (item !== undefined && item.type === "Display") {
				if (item.state === true) {
					$('#Container').show();
				} else {
					$('#Container').hide();
				}
			}
		});
	};
});

// setTimeout(() => {function();}, 2000);