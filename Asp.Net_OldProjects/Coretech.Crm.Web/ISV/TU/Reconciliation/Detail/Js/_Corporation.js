function ActionTemplate(TransferId, Action, RefNumber, TuStatusCode) {
    if (TransferId == "" || Action == 0 || TuStatusCode == 'TR002A')
        return RefNumber;

    return String.format(
            "<a href=javascript:Integrate('{0}','{1}') ><img src='" + GetWebAppRoot + "/images/bullet.png' width=12 height=12 />{2}<div  class='cell-imagecommand icon-button '></div></a>",
            TransferId, Action, RefNumber);
}

function Integrate(id, Action) {
    HdnChTransferId.setValue(id);
    HdnActionId.setValue(Action);
    BtnAction.click();
}