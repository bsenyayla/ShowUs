Ext.override(Ext.data.Store, {
    sortState: [],
    sort: function (fieldName, dir) {
        this.sortByFields([{
            field: fieldName,
            direction: dir
        }]);
    },
    sortByFields: function (newFields, add) {
        var fields = this.sortState;

        //Todo: see if ext has an exisiting lookup implementation
        var lookupfn = function (arr, field) {
            var index = Ext.each(arr, function (item) {
                if (item.field == field)
                    return false;
            })
            if (index === undefined)
                return -1;
            return index;
        }

        //        if(!add)
        //            fields = []

        Ext.each(newFields, function (item, i) {
            var doFlip = false;
            if (typeof item == 'string') {
                item = {
                    field: item,
                    direction: 'ASC'
                };
                doFlip = true;
            }
            var oldIndex = lookupfn(this.sortState, item.field);
            if (oldIndex >= 0) {
                if (add) {
                    //unselect the field if ctrl is pressed again on an already sorted column                    
                    fields.splice(oldIndex, 1);
                }
                else {
                    fields[oldIndex].direction = (doFlip ? (this.sortState[oldIndex].direction == 'ASC' ? 'DESC' : 'ASC') : item.direction);
                }
            }
            else {
                //only create completely new selection if an unsorted column is clicked withou CTRL pressed                
                if (!add && i === 0) {
                    fields = [];
                }
                fields.push(item);
            }

        }, this);

        var si = (this.sortInfo) ? this.sortInfo : null;

        this.sortInfo = fields;
        this.sortState = fields;
        if (!this.remoteSort) {

            var st = [];
            for (var i = 0; i < fields.length; i++) {
                st.push(this.fields.get(fields[i].field).sortType);
            }
            this.sortState = fields;

            var fn = function (r1, r2) {
                var result;
                for (var i = 0; !result && i < fields.length; i++) {
                    var v1 = st[i](r1.data[fields[i].field]);
                    var v2 = st[i](r2.data[fields[i].field]);
                    result = (v1 > v2) ? 1 : ((v1 < v2) ? -1 : 0);
                    if (fields[i].direction == 'DESC') result = -result;
                }
                return result;
            };
            this.data.sort('ASC', fn);
            if (this.snapshot && this.snapshot != this.data) {
                this.snapshot.sort('ASC', fn);
            }
            this.fireEvent("datachanged", this);
        }
        else {
            if (!this.load(this.lastOptions)) {
                if (si) {
                    this.sortInfo = si;
                }
            }
        }
    },
    load: function (options) {
        options = options || {};
        if (this.fireEvent("beforeload", this, options) !== false) {
            this.storeOptions(options);
            var p = Ext.apply(options.params || {}, this.baseParams);
            if (this.sortInfo && this.remoteSort) {
                var pn = this.paramNames;
                p[pn.sort] = this.sortInfo.field ? this.sortInfo.field : Ext.encode(this.sortInfo);
                p[pn.dir] = this.sortInfo.direction ? this.sortInfo.direction : null;
            }
            this.proxy.load(p, this.reader, this.loadRecords, this, options);
            return true;
        } else {
            return false;
        }
    } 
});

Ext.override(Ext.grid.GridView, {
    // private
    onHeaderClick: function (g, index, evt) {

        if (this.headersDisabled || !this.cm.isSortable(index)) {
            return;
        }
        g.stopEditing(true);
        if (evt.ctrlKey)
            g.store.sortByFields([this.cm.getDataIndex(index)], true);
        else
            g.store.sortByFields([this.cm.getDataIndex(index)]);
    },

    // private
    updateHeaderSortState: function () {
        var state = this.ds.sortState;
        if (!state.length) {
            return;
        }
        if (!this.sortState || (this.sortState != state)) {
            this.grid.fireEvent('sortchange', this.grid, state);
        }
        this.sortState = state;
        this.mainHd.select('td').removeClass(this.sortClasses);
        Ext.each(state, function (state) {
            if (typeof state != 'function') {
                var sortColumn = this.cm.findColumnIndex(state.field);
                if (sortColumn != -1) {
                    var sortDir = state.direction;
                    this.updateSortIcon(sortColumn, sortDir);
                }
            }
        }, this)
    },

    updateSortIcon: function (col, dir) {
        var sc = this.sortClasses;
        var hds = this.mainHd.select('td');
        hds.item(col).addClass(sc[dir == "DESC" ? 1 : 0]);
    }
})