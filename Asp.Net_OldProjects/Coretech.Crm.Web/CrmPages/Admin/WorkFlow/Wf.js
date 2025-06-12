function _AddUpdateParentCondition(_Name, _TemplateId, _laction, _type) {
    if (FrameWorkType != "RefleX") {

        var frame = null;
        if (window.top.frames[lframename] != null)
            frame = window.top.frames[lframename];
        else if (window.parent.name == lframename)
            frame = window.parent;

        frame.AddUpdateCondition(_Name, _TemplateId, _laction, _type)
        top.Ext.WindowMgr.getActive().close()
    }
    else {
       
        var win = window.top.R.WindowMng.getWindowById(awinid);
        var pid=win.frame.id;
        for (var i = 0; i < window.top.frames.length; i++) {
            if (window.top.frames[i].name == pid) {
                window.top.frames[i].AddUpdateCondition(_Name, _TemplateId, _laction, _type);
            }
        }
        
        window.top.R.WindowMng.getActiveWindow().hide()
    }
}

