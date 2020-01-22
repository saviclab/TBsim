window.globals = {
  population_plots_available: false,
  population_quick_sim: true,
  single_plots_available: false,
  show_save_single: false,
  username: null,
  population_selected_id: null,
  single_selected_id: null
};
document.title = "TBsim" ; //override default set by shinyDashboard
$(document).ready(function() {

  $("#simRefreshSingle").click();

  $("#singlePatientResultsTable").click(function() {
    var n = $("#singlePatientResultsTable > div > table > tbody > tr.selected").length;
    var id = $("#singlePatientResultsTable > div > table > tbody > tr.selected > td:nth-child(2)").html();
    if(n == 1) {
      $("#reportSingle").removeClass('disabled');
      $("#downloadDataSingle").removeClass('disabled');
      window.globals.single_selected_id = id;
      Shiny.onInputChange("single_selected_id", id);
    } else {
      $("#reportSingle").addClass('disabled');
      $("#downloadDataSingle").addClass('disabled');
      window.globals.single_selected_id = null;
      Shiny.onInputChange("single_selected_id", null);
    }
  });
  $("#queueResultsTable").click(function() {
    var n = $("#queueResultsTable > div > table > tbody > tr.selected").length;
    var id = $("#queueResultsTable > div > table > tbody > tr.selected > td:nth-child(2)").html();
    if(n == 1) {
      $("#reportPopulation").removeClass('disabled');
      $("#downloadDataPopulation").removeClass('disabled');
      window.globals.population_selected_id = id;
      Shiny.onInputChange("population_selected_id", id);
    } else {
      $("#reportPopulation").addClass('disabled');
      $("#downloadDataPopulation").addClass('disabled');
      window.globals.population_selected_id = null;
      Shiny.onInputChange("population_selected_id", null);
    }
  });

  Shiny.addCustomMessageHandler("get_selected_id",
    function(message) {
    }
  );

  Shiny.addCustomMessageHandler("popup",
    function(message) {
        var msg = {
          title: "Message",
          text: message[0],
          cancelButtonColor: "#DD6B55",
          confirmButtonColor: "#052049"
        };
        if(message[1]) {
          msg.title = message[1];
        }
        swal(msg);
    }
  );

  Shiny.addCustomMessageHandler("clickButton",
    function(message) {
      $("#" + message[0]).click();
    }
  );

  Shiny.addCustomMessageHandler("setButtonState",
    function(message) {
      if(message[1] == "disabled") {
        $("#"+message[0]).prop('disabled', true);
      } else {
        $("#"+message[0]).prop('disabled', false);
      }
    }
  );

  Shiny.addCustomMessageHandler("setAnchorState",
    function(message) {
      if(message[1] == "disabled") {
        $("#"+message[0]).addClass('disabled', true);
      } else {
        $("#"+message[0]).removeClass('disabled', false);
      }
    }
  );

  Shiny.addCustomMessageHandler("hideElement",
    function(message) {
      $(message[0]).addClass('hide');
    }
  );
  Shiny.addCustomMessageHandler("showElement",
    function(message) {
      $(message[0]).removeClass('hide');
    }
  );
  Shiny.addCustomMessageHandler("setElementText",
    function(message) {
      $(message[0]).text(message[1]);
    }
  );
  Shiny.addCustomMessageHandler("checkCheckbox",
    function(message) {
      $("#"+message[0]).prop('checked', true);
    }
  );
  Shiny.addCustomMessageHandler("uncheckCheckbox",
    function(message) {
      $("#"+message[0]).prop('checked', false);
    }
  );

  Shiny.addCustomMessageHandler("openModal",
    function(message) {
      $("#"+message[0]).modal('show');
    }
  );

  Shiny.addCustomMessageHandler("closeModal",
    function(message) {
      $("#"+message[0]).modal('hide');
    }
  );

  Shiny.addCustomMessageHandler("switchUserLevel",
    function(message) {
        if(message[0] == "Basic") {
          // $("[data-value='Immune system']").addClass('hide');
          // $("[data-value='Bactericidal effect']").addClass('hide');
          // $("ul.sidebar-menu li:nth-child(2)" ).addClass('hide'); // drugMenu
          // $(".outcome-box").addClass('hide');
        } else {
          // $("[data-value='Immune system']").removeClass('hide');
          // $("[data-value='Bactericidal effect']").removeClass('hide');
          // $("ul.sidebar-menu li:nth-child(2)" ).removeClass('hide');
          // $(".outcome-box").removeClass('hide');
        }
    }
  );

  Shiny.addCustomMessageHandler("setGlobal",
    function(message) {
      window.globals[message[0]] = message[1];
    }
  );
  Shiny.addCustomMessageHandler("toggleGlobal",
    function(message) {
      window.globals[message[0]] = !window.globals[message[0]];
    }
  );

  Shiny.addCustomMessageHandler("refreshQueue",
    function(message) {
      window.globals.username = message[0];
      setTimeout(function() {
        $("#refreshJobQueue").click();
        $("#refreshResults").click();
      });
    }
  );

  Shiny.addCustomMessageHandler("refreshJobs",
    function(message) {
      var delay = message[0];
      swal("Job scheduled for stopping.");
      setTimeout(function() {
        $("#refreshJobQueue").click();
      }, delay);
    }
  );

  Shiny.addCustomMessageHandler("refreshResults",
    function(message) {
      var delay = message[0];
      setTimeout(function() {
        $("#refreshResults").click();
        $("#singlePatientRefreshResults").click();
      }, delay);
    }
  );

  Shiny.addCustomMessageHandler("activateTab",
    function(message) {
      $("[data-value='"+message[0]+"'").click();
    }
  );

  Shiny.addCustomMessageHandler("showTab",
    function(message) {
      $("[data-value='"+message[0]+"'").removeClass('hide');
    }
  );

  Shiny.addCustomMessageHandler("hideTab",
    function(message) {
      console.log(message[0]);
      $("[data-value='"+message[0]+"'").addClass('hide');
    }
  );

});
