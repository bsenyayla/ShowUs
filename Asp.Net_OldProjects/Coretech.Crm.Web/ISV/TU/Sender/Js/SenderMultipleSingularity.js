function ShowWindow(Id)
{
    window.parent.frames[2].location = window.parent.frames[2].location + "&recid=" + Id;
    window.top.R.WindowMng.getActiveWindow().hide();
}