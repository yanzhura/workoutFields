import Toybox.Application;
import Toybox.System;
import Toybox.Activity;
import Toybox.Lang;
import Toybox.Time;
import Toybox.WatchUi;
import Toybox.Graphics;

const INTENSITY_NAMES = [
    "ACTIVE",
    "REST",
    "WARMUP",
    "COOLDOWN",
    "RECOVERY",
    "INTERVAL"
];

class workoutFieldsView extends WatchUi.DataField {
    hidden var _cx;
    hidden var _cy;
    hidden var _font;
    hidden var _font_height;
    hidden var _justification;

    hidden var displayData = [];

    function initialize() {
        DataField.initialize();
    }

    function onLayout(dc) {
        _cx = dc.getWidth() / 2;
        _cy = dc.getHeight() / 2;
        _font = Graphics.FONT_XTINY;
        _font_height = dc.getFontHeight(_font);
        // _justification = Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER;
        _justification = Graphics.TEXT_JUSTIFY_LEFT | Graphics.TEXT_JUSTIFY_VCENTER;
    }

    function setDisplayData(label, value) {
        displayData.add(Lang.format("$1$: $2$", [ label, value ]));
    }

    function parseCurrentWorkout(workoutInfo) {
        if (workoutInfo != null){
            if(workoutInfo has :name){
                setDisplayData("exercise", workoutInfo.name);
            } else {
                setDisplayData("exercise", "n/a");
            }
            if(workoutInfo has :notes){
                setDisplayData("note", workoutInfo.notes);
            } else {
                setDisplayData("note", "-");
            }
            if(workoutInfo has :intensity){
                setDisplayData("intensity", INTENSITY_NAMES[workoutInfo.intensity]);
            }
            if (workoutInfo has :step) {
                var workoutStep = workoutInfo.step;
                if (workoutStep has :repetitionNumber) {
                    setDisplayData("repetition", workoutStep.repetitionNumber);
                }
            }
        }
    }

    function parseNextWorkout(nextWorkoutInfo) {
        if (nextWorkoutInfo != null){
            if(nextWorkoutInfo has :name){
                setDisplayData("nextExercise", nextWorkoutInfo.name);
            }
            if(nextWorkoutInfo has :notes){
                setDisplayData("nextNote", nextWorkoutInfo.notes);
            }
            if(nextWorkoutInfo has :intensity){
                setDisplayData("nextIntensity", INTENSITY_NAMES[nextWorkoutInfo.intensity]);
            }
        }
    }

     function onWorkoutStarted() {
        displayData = [];

        if (Activity has :getCurrentWorkoutStep) {
            var currentStepInfo = Activity.getCurrentWorkoutStep();
            parseCurrentWorkout(currentStepInfo);
        }
        if (Activity has :getNextWorkoutStep) {
            var nextStepInfo = Activity.getNextWorkoutStep();
            parseNextWorkout(nextStepInfo);
        }

        WatchUi.requestUpdate();
    }

    function onWorkoutStepComplete() {
        displayData = [];

        if (Activity has :getCurrentWorkoutStep) {
            var currentStepInfo = Activity.getCurrentWorkoutStep();
            parseCurrentWorkout(currentStepInfo);
        }
        if (Activity has :getNextWorkoutStep) {
            var nextStepInfo = Activity.getNextWorkoutStep();
            parseNextWorkout(nextStepInfo);;
        }

        WatchUi.requestUpdate();
    }

    function onUpdate(dc) {
        dc.clear();
        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_WHITE);

        var cy = _cy - (displayData.size() * _font_height) / 2;

        for (var i = 0; i < displayData.size(); ++i) {
            dc.drawText(20, cy + (_font_height * i), _font, displayData[i], _justification);
            // dc.drawText(_cx, cy + (_font_height * i), _font, displayData[i], _justification);
        }
    }

}

class workoutFieldsApp extends Application.AppBase {

    function initialize() {
        AppBase.initialize();
    }

    function getInitialView() {
        return [ new workoutFieldsView() ];
    }

}