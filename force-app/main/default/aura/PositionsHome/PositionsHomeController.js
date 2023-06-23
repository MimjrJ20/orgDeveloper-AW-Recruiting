({
    doInit: function(component, event, helper){
        var action = component.get("c.getPositionsAndAccount");
        action.setCallback(this, function(data){
            component.set("v.Positions", data.getReturnValue());
            console.log(data.getReturnValue());
        });
        $A.enqueueAction(action);
    }
})