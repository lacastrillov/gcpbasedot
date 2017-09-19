<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<script>

function ${entityName}ExtView(parentExtController, parentExtView){
    
    var Instance= this;
    
    Instance.id= "/${entityRef}";
    
    Instance.modelName="${entityName}Model";
    
    var util= new Util();
    
    // MODELS **********************************************
    
    Instance.entityExtModel= new ${entityName}ExtModel();
    
    // STORES **********************************************
    
    Instance.entityExtStore= new ${entityName}ExtStore();
    
    // COMPONENTS *******************************************
    
    Instance.commonExtView= new CommonExtView(parentExtController, Instance, '${entityName}');
    
    //*******************************************************
    
    
    Instance.init= function(){
        Instance.typeView= "${typeView}";
        Instance.pluralEntityTitle= '${viewConfig.pluralEntityTitle}';
        Instance.entityExtModel.defineModel(Instance.modelName);
        Instance.store= Instance.entityExtStore.getStore(Instance.modelName);
        <c:if test="${viewConfig.activeGridTemplate}">
        Instance.gridModelName= "${entityName}TemplateModel";
        Instance.entityExtModel.defineTemplateModel(Instance.gridModelName);
        Instance.gridStore= Instance.entityExtStore.getTemplateStore(Instance.gridModelName);
        </c:if>
        Instance.createMainView();
    };
    
    Instance.setFilterStore= function(filter){
        <c:if test="${not viewConfig.activeGridTemplate}">
            Instance.store.getProxy().extraParams.filter= filter;
        </c:if>
        <c:if test="${viewConfig.activeGridTemplate}">
            Instance.gridStore.getProxy().extraParams.filter= filter;
        </c:if>
    };
    
    Instance.reloadPageStore= function(page){
        <c:if test="${not viewConfig.activeGridTemplate}">
            Instance.store.loadPage(page);
        </c:if>
        <c:if test="${viewConfig.activeGridTemplate}">
            Instance.gridStore.loadPage(page);
        </c:if>
    };
    
    <c:if test="${viewConfig.activeNNMulticheckChild}">
    Instance.clearNNMultichecks= function(){
        var checkboxGroup=Ext.getCmp('checkboxGroup${viewConfig.entityRefNNMulticheckChild}In${entityName}');
        if(checkboxGroup.items.length > 0 && checkboxGroup.items.items.length > 0){
            checkboxGroup.items.items.forEach(function(checkbox){
                checkbox.activeChange=false;
                checkbox.setValue(false);
                checkbox.activeChange=true;
            });
        }
    }
    
    Instance.findAndLoadNNMultichecks= function(filter){
        Instance.entityExtStore.find(filter, "", function(responseText){
            if(responseText.success){
                responseText.data.forEach(function(item){
                    var itemCheckValue= item.${viewConfig.entityRefNNMulticheckChild}.id;
                    var checkbox= Ext.getCmp('checkNN${viewConfig.entityRefNNMulticheckChild}'+itemCheckValue);
                    checkbox.activeChange=false;
                    checkbox.setValue(true);
                    checkbox.activeChange=true;
                });
            }
        });
    };
    </c:if>
    
    <c:if test="${viewConfig.visibleForm}">
    function getFormContainer(modelName, store, childExtControllers){
        var formFields= ${jsonFormFields};

        var renderReplacements= ${jsonRenderReplacements};

        var additionalButtons= ${jsonInternalViewButtons};

        Instance.defineWriterForm(Instance.modelName, formFields, renderReplacements, additionalButtons, childExtControllers, Instance.typeView);
        
        var itemsForm= [{
            itemId: 'form'+modelName,
            xtype: 'writerform'+modelName,
            border: false,
            width: '100%',
            listeners: {
                create: function(form, data){
                    Instance.entityExtStore.save('create', JSON.stringify(data), parentExtController.formSavedResponse);
                },
                update: function(form, data){
                    Instance.entityExtStore.save("update", JSON.stringify(data), parentExtController.formSavedResponse);
                },
                render: function(panel) {
                    Instance.commonExtView.enableManagementTabHTMLEditor();
                }
            }
        }];
        
        if(Instance.typeView==="Parent"){
            itemsForm.push(getChildsExtViewTabs(childExtControllers));
        }
        
        return Ext.create('Ext.container.Container', {
            id: 'formContainer'+modelName,
            title: 'Formulario',
            type: 'fit',
            align: 'stretch',
            items: itemsForm
        });
    };
    
    function getChildsExtViewTabs(childExtControllers){
        var items=[];
        var jsonTypeChildExtViews= ${jsonTypeChildExtViews};
        childExtControllers.forEach(function(childExtController) {
            var itemTab= null;
            if(jsonTypeChildExtViews[childExtController.entityRef]==="tcv_standard"){
                itemTab= {
                    xtype:'tabpanel',
                    title: childExtController.entityExtView.pluralEntityTitle,
                    plain:true,
                    activeTab: 0,
                    style: 'background-color:#dfe8f6; padding:10px;',
                    defaults: {bodyStyle: 'padding:15px', autoScroll:true},
                    items:[
                        childExtController.entityExtView.gridContainer,

                        childExtController.entityExtView.formContainer

                    ]
                };
            }else if(jsonTypeChildExtViews[childExtController.entityRef]==="tcv-n-n-multicheck"){
                itemTab= childExtController.entityExtView.checkboxGroupContainer;
            }
            
            items.push(itemTab);
        });
        
        var tabObect= {
            xtype:'tabpanel',
            plain:true,
            activeTab: 0,
            style: 'padding:25px 15px 45px 15px;',
            items:items
        };
        
        return tabObect;
    };
    
    Instance.setFormActiveRecord= function(record){
        var formComponent= Instance.formContainer.child('#form'+Instance.modelName);
        formComponent.setActiveRecord(record || null);
    };
    
    Instance.defineWriterForm= function(modelName, fields, renderReplacements, additionalButtons){
        Ext.define('WriterForm'+modelName, {
            extend: 'Ext.form.Panel',
            alias: 'widget.writerform'+modelName,

            requires: ['Ext.form.field.Text'],

            initComponent: function(){
                //this.addEvents('create');
                
                var buttons= [];
                <c:if test="${viewConfig.editableForm}">
                buttons= [{
                    iconCls: 'icon-save',
                    itemId: 'save'+modelName,
                    text: 'Actualizar',
                    disabled: true,
                    scope: this,
                    handler: this.onSave
                },
                <c:if test="${not viewConfig.preloadedForm}">
                {
                    //iconCls: 'icon-user-add',
                    text: 'Crear',
                    scope: this,
                    handler: this.onCreate
                }, {
                    //iconCls: 'icon-reset',
                    text: 'Limpiar',
                    scope: this,
                    handler: this.onReset
                },
                </c:if>
                '|'];
                </c:if>
                if(additionalButtons){
                    for(var i=0; i<additionalButtons.length; i++){
                        buttons.push(additionalButtons[i]);
                    }
                }
                Ext.apply(this, {
                    activeRecord: null,
                    //iconCls: 'icon-user',
                    frame: false,
                    defaultType: 'textfield',
                    bodyPadding: 15,
                    fieldDefaults: {
                        minWidth: 300,
                        anchor: '50%',
                        labelAlign: 'right'
                    },
                    items: fields,
                    dockedItems: [{
                        xtype: 'toolbar',
                        dock: 'bottom',
                        ui: 'footer',
                        items: buttons
                    }]
                });
                this.callParent();
            },

            setActiveRecord: function(record){
                this.activeRecord = record;
                if (this.activeRecord) {
                    if(this.down('#save'+modelName)!==null){
                        this.down('#save'+modelName).enable();
                    }
                    this.getForm().loadRecord(this.activeRecord);
                    //this.getForm().setValues(this.activeRecord.data);
                    this.renderReplaceActiveRecord(this.activeRecord);
                } else {
                    if(this.down('#save'+modelName)!==null){
                        this.down('#save'+modelName).disable();
                    }
                    this.getForm().reset();
                }
            },
                    
            getActiveRecord: function(){
                return this.activeRecord;
            },
            
            onSave: function(){
                var active = this.activeRecord,
                    form = this.getForm();
            
                if (!active) {
                    return;
                }
                if (form.isValid()) {
                    this.fireEvent('update', this, form.getValues());
                    //form.updateRecord(active);
                    //this.onReset();
                }
            },

            onCreate: function(){
                var form = this.getForm();

                if (form.isValid()) {
                    this.fireEvent('create', this, form.getValues());
                    //form.reset();
                }

            },

            onReset: function(){
                this.getForm().reset();
                parentExtController.loadFormData("");
            },
            
            renderReplaceActiveRecord: function(record){
                if(renderReplacements){
                    for(var i=0; i<renderReplacements.length; i++){
                        var renderReplace= renderReplacements[i];
                        var replaceField= renderReplace.replace.field;
                        var replaceAttribute= renderReplace.replace.attribute;
                        var value="";
                        
                        if (typeof record.data[replaceField] === "object" && Object.getOwnPropertyNames(record.data[replaceField]).length === 0){
                            value= "";
                        }else if(replaceAttribute.indexOf(".")===-1 && replaceField in record.data){
                            value= record.data[replaceField][replaceAttribute];
                        }else{
                            var niveles= replaceAttribute.split(".");
                            try{
                                switch(niveles.length){
                                    case 2:
                                        value= record.data[replaceField][niveles[0]][niveles[1]];
                                        break;
                                    case 3:
                                        value= record.data[replaceField][niveles[0]][niveles[1]][niveles[2]];
                                        break;
                                    case 4:
                                        value= record.data[replaceField][niveles[0]][niveles[1]][niveles[2]][niveles[3]];
                                        break;
                                    case 5:
                                        value= record.data[replaceField][niveles[0]][niveles[1]][niveles[2]][niveles[3]][niveles[4]];
                                        break;
                                }
                            }catch(err){
                                console.log(err);
                            }
                            
                        }
                        if(typeof(value) !== 'undefined'){
                            renderReplace.component.setValue(value);
                        }
                    }
                }
                return record;
            }
    
        });
        
    };
    
    </c:if>
    
    <c:if test="${viewConfig.visibleGrid}">
    function getGridContainer(modelName, store, formContainer){
        var idGrid= 'grid'+modelName;
        var gridColumns= ${jsonGridColumns};
        
        Instance.emptyModel= ${jsonEmptyModel};
        Instance.getEmptyRec= function(){
            return new ${entityName}Model(Instance.emptyModel);
        };
        
        <c:if test="${viewConfig.activeGridTemplate}">
        modelName= Instance.gridModelName;
        store= Instance.gridStore;
        </c:if>

        Instance.defineWriterGrid(modelName, '${viewConfig.pluralEntityTitle}', gridColumns, Instance.typeView);
        
        return Ext.create('Ext.container.Container', {
            id: 'gridContainer'+modelName,
            title: 'Listado',
            <c:if test="${viewConfig.gridHeightChildView != 0}">
            height: ${viewConfig.gridHeightChildView},
            </c:if>
            layout: {
                type: 'vbox',
                align: 'stretch'
            },
            items: [{
                itemId: idGrid,
                xtype: 'writergrid'+modelName,
                style: 'border: 0px',
                flex: 1,
                store: store,
                disableSelection: ${viewConfig.activeGridTemplate},
                trackMouseOver: !${viewConfig.activeGridTemplate},
                listeners: {
                    selectionchange: function(selModel, selected) {
                        if(selected[0]){
                            parentExtController.setFormData(selected[0]);
                        }
                    },
                    export: function(typeReport){
                        var filterData= JSON.stringify(parentExtController.filter);
                        filterData= filterData.replaceAll("{","(").replaceAll("}",")");
                        var data= "?filter="+filterData;
                        data+="&limit="+store.pageSize+"&page="+store.currentPage;
                        data+="&sort="+store.getOrderProperty()+"&dir="+store.getOrderDir();
                        
                        switch(typeReport){
                            case "json":
                                var urlFind= store.proxy.api.read;
                                window.open(urlFind+data,'_blank');
                                break;
                            case "xml":
                                var urlFind= store.proxy.api.read.replace("find.htm","find/xml.htm");
                                window.open(urlFind+data,'_blank');
                                break;
                            case "xls":
                                var urlFind= store.proxy.api.read.replace("find.htm","find/xls.htm");
                                window.open(urlFind+data,'_blank');
                                break;
                        }
                    }
                    
                }
            }],
            listeners: {
                activate: function(panel) {
                    //store.loadPage(1);
                }
            }
        });
    };
    
    Instance.setValueInEmptyModel= function(fieldName, value){
        Instance.emptyModel[fieldName]= value;
        Instance.getEmptyRec= function(){
            return new ${entityName}Model(Instance.emptyModel);
        };
    };
    
    function getComboboxLimit(store){
        var combobox= Instance.commonExtView.getSimpleCombobox('limit', 'L&iacute;mite', 'config', [50, 100, 200, 500]);
        combobox.addListener('change',function(record){
            if(record.getValue()!=="" && store.pageSize!==record.getValue()){
                store.pageSize=record.getValue();
                Instance.reloadPageStore(1);
            }
        }, this);
        combobox.labelWidth= 46;
        combobox.width= 125;
        combobox.setValue(${viewConfig.maxResultsPerPage});
        
        return combobox;
    }
    
    function getComboboxOrderBy(store){
        var combobox= Instance.commonExtView.getSimpleCombobox('sort', 'Ordenar por', 'config', ${sortColumns});
        combobox.addListener('change',function(record){
            if(record.getValue()!=="" && store.getOrderProperty()!==record.getValue()){
                var dir= store.getOrderDir();
                store.sortBy(record.getValue(), dir);
                Instance.reloadPageStore(1);
            }
        }, this);
        combobox.labelWidth= 80;
        combobox.width= 250;
        combobox.setValue("${viewConfig.defaultOrderBy}");
        
        return combobox;
    }
    
    function getComboboxOrderDir(store){
        var combobox= Instance.commonExtView.getSimpleCombobox('dir', 'Direcci&oacute;n', 'config', ["ASC", "DESC"]);
        combobox.addListener('change',function(record){
            if(record.getValue()!=="" && store.getOrderDir()!==record.getValue()){
                var prop= store.getOrderProperty();
                store.sortBy(prop, record.getValue());
                Instance.reloadPageStore(1);
            }
        }, this);
        combobox.labelWidth= 60;
        combobox.width= 150;
        combobox.setValue("${viewConfig.defaultOrderDir}");
        
        return combobox;
    }
    
    Instance.defineWriterGrid= function(modelName, modelText, columns, typeView){
        Ext.define('WriterGrid'+modelName, {
            extend: 'Ext.grid.Panel',
            alias: 'widget.writergrid'+modelName,

            requires: [
                'Ext.grid.plugin.CellEditing',
                'Ext.form.field.Text',
                'Ext.toolbar.TextItem'
            ],

            initComponent: function(){

                this.editing = Ext.create('Ext.grid.plugin.CellEditing');
                

                Ext.apply(this, {
                    //iconCls: 'icon-grid',
                    hideHeaders:${viewConfig.hideHeadersGrid},
                    frame: false,
                    plugins: [this.editing],
                    dockedItems: [{
                        weight: 2,
                        xtype: 'toolbar',
                        dock: 'bottom',
                        items: [{
                            xtype: 'tbtext',
                            text: '<b>@lacv</b>'
                        }, '|',
                        <c:if test="${viewConfig.editableGrid && viewConfig.visibleAddButtonInGrid}">
                        {
                            //iconCls: 'icon-add',
                            text: 'Agregar',
                            scope: this,
                            handler: this.onAddClick
                        },
                        </c:if>
                        <c:if test="${viewConfig.visibleRemoveButtonInGrid}">
                        {
                            //iconCls: 'icon-delete',
                            text: 'Eliminar',
                            <c:if test="${not viewConfig.activeGridTemplate}">
                            disabled: true,
                            </c:if>
                            itemId: 'delete',
                            scope: this,
                            handler: this.onDeleteClick
                        },
                        </c:if>
                        
                        <c:if test="${viewConfig.visibleExportButton}">
                        {
                            text: 'Exportar',
                            //iconCls: 'add16',
                            menu: [
                                {text: 'A xls', handler: function(){this.exportTo('xls');}, scope: this},
                                {text: 'A json', handler: function(){this.exportTo('json');}, scope: this},
                                {text: 'A xml', handler: function(){this.exportTo('xml');}, scope: this}]
                        },
                        </c:if>
                        <c:if test="${viewConfig.editableGrid}">
                        {
                            text: 'Auto-Guardar',
                            enableToggle: ${viewConfig.defaultAutoSave},
                            pressed: true,
                            tooltip: 'When enabled, Store will execute Ajax requests as soon as a Record becomes dirty.',
                            scope: this,
                            toggleHandler: function(btn, pressed){
                                this.store.autoSync = pressed;
                            }
                        }, {
                            iconCls: 'icon-save',
                            text: 'Guardar',
                            scope: this,
                            handler: this.onSync
                        },
                        </c:if>
                        getComboboxLimit(this.store),
                        getComboboxOrderBy(this.store),
                        getComboboxOrderDir(this.store)
                        ]
                    }, {
                        weight: 1,
                        xtype: 'pagingtoolbar',
                        dock: 'bottom',
                        ui: 'footer',
                        store: this.store,
                        displayInfo: true,
                        displayMsg: modelText+' {0} - {1} de {2}',
                        emptyMsg: "No hay "+modelText
                    }],
                    columns: columns
                });
                this.callParent();
                this.getSelectionModel().on('selectionchange', this.onSelectChange, this);
            },

            onSelectChange: function(selModel, selections){
                if(this.down('#delete')!==null){
                    this.down('#delete').setDisabled(selections.length === 0);
                }
            },

            onSync: function(){
                this.store.sync();
            },

            onDeleteClick: function(){
                var selection = this.getView().getSelectionModel().getSelection()[0];
                if (selection) {
                    this.store.getProxy().extraParams.idEntity= selection.data.id;
                    this.store.remove(selection);
                    parentExtController.loadFormData("");
                }else{
                    var check_items= document.getElementsByClassName("item_check");
                    var filter={"in":{"id":[]}};
                    for(var i=0; i<check_items.length; i++){
                        if(check_items[i].checked){
                            filter.in.id.push(check_items[i].value);
                        }
                    }
                    if(filter.in.id.length>0){
                        Instance.entityExtStore.deleteByFilter(JSON.stringify(filter), function(responseText){
                            Instance.reloadPageStore(Instance.store.currentPage);
                        });
                    }
                }
            },

            onAddClick: function(){
                var rec = Instance.getEmptyRec(), edit = this.editing;
                edit.cancelEdit();
                this.store.insert(0, rec);
                edit.startEditByPosition({
                    row: 0,
                    column: 0
                });
            },
            
            exportTo: function(type){
                this.fireEvent('export', type);
            }

        });
    };
    </c:if>

    <c:if test="${viewConfig.activeNNMulticheckChild}">
    function getCheckboxGroupContainer(){
        var checkboxGroupContainer= Ext.create('Ext.container.Container', {
            title: 'Lista '+Instance.${viewConfig.entityRefNNMulticheckChild}ExtInterfaces.pluralEntityTitle,
            style: 'background-color:#dfe8f6; padding:10px;',
            layout: 'anchor',
            defaults: {
                anchor: '100%'
            },
            items: [
                Instance.${viewConfig.entityRefNNMulticheckChild}ExtInterfaces.getCheckboxGroup('${entityName}', '${viewConfig.entityRefNNMulticheckChild}',
                function (checkbox, isChecked) {
                    if(checkbox.activeChange){
                        var record= Ext.create(Instance.modelName);
                        if(Object.keys(parentExtController.filter.eq).length !== 0){
                            for (var key in parentExtController.filter.eq) {
                                record.data[key]= parentExtController.filter.eq[key];
                            }
                        }
                        record.data[checkbox.name]= checkbox.inputValue;
                        if(isChecked){
                            Instance.entityExtStore.save('create', JSON.stringify(record.data), function(responseText){
                                console.log(responseText.data);
                            });
                        }else{
                            var filter= record.data;
                            delete filter["id"];
                            Instance.entityExtStore.deleteByFilter(JSON.stringify({"eq":filter}), function(responseText){
                                console.log(responseText.data);
                            });
                        }
                    }
                })
            ]
        });
        
        return checkboxGroupContainer;
    }
    </c:if>
    
    function getPropertyGrid(){
        var renderers= {
            <c:forEach var="associatedER" items="${interfacesEntityRef}">
                <c:set var="associatedEntityName" value="${fn:toUpperCase(fn:substring(associatedER, 0, 1))}${fn:substring(associatedER, 1,fn:length(associatedER))}"></c:set>
            ${associatedEntityName}: function(entity){
                var res = entity.split("__");
                return '<a href="<%=request.getContextPath()%>/vista/${associatedER}/entity.htm#?tab=1&id='+res[0]+'">'+res[1]+'</a>';
            },
            </c:forEach>
        };
        var pg= Ext.create('Ext.grid.property.Grid', {
            id: 'propertyGrid${entityName}',
            region: 'north',
            hideHeaders: true,
            resizable: false,
            defaults: {
                sortable: false
            },
            customRenderers: renderers,
            disableSelection:true,
            listeners: {
                'beforeedit':{
                    fn:function(){
                        return false;
                    }
                }
            }
        });
        pg.getStore().sorters.items= [];
        
        return pg;
    };
    
    <c:forEach var="processButton" items="${viewConfig.processButtons}">
    function getForm${processButton.processName}Process(){
        
        var processForm = Ext.create('Ext.form.Panel', {
            itemId: 'form${processButton.processName}Process',
            defaultType: 'textfield',
            border: false,
            bodyPadding: 15,
            autoScroll: true,
            fieldDefaults: {
                minWidth: 300,
                anchor: '100%',
                labelAlign: 'right'
            },

            items: ${jsonFormFieldsProcessMap[processButton.processName]}
        });

        var win = Ext.create('Ext.window.Window', {
            autoShow: false,
            title: '${processButton.processTitle}',
            closable: true,
            closeAction: 'hide',
            width: '50%',
            height: 300,
            minWidth: 300,
            minHeight: 200,
            layout: 'fit',
            plain:true,
            maximizable: true,
            minimizable: true,
            items: processForm,

            buttons: [{
                text: 'Ejecutar',
                handler: function(){
                    var jsonData= processForm.getForm().getValues();
                    Instance.entityExtStore.doProcess('${processButton.mainProcessRef}', '${processButton.processName}', jsonData, function(responseText){
                        Ext.MessageBox.alert('Status', responseText);
                        win.hide();
                    });
                }
            },{
                text: 'Cancelar',
                handler: function(){
                    win.hide();
                }
            }],
            listeners: {
                "minimize": function (window, opts) {
                    window.collapse();
                    window.setWidth(150);
                    window.alignTo(Ext.getBody(), 'bl-bl')
                }
            },
            tools: [{
                type: 'restore',
                handler: function (evt, toolEl, owner, tool) {
                    var window = owner.up('window');
                    window.setWidth(600);
                    window.setHeight(300);
                    window.expand('', false);
                    window.center();
                }
            }]
        });
        
        return win;
    }
    </c:forEach>
    
    Instance.showProcessForm= function(processName, sourceByDestinationFields, rowIndex){
        var initData={};
        if(rowIndex!==-1){
            var rec = Instance.gridContainer.child('#grid'+Instance.modelName).getStore().getAt(rowIndex);
            for (var source in sourceByDestinationFields) {
                var destination = sourceByDestinationFields[source];
                initData[destination]=rec.get(source);
            }
            
        }else{
            var formData= Instance.formContainer.child('#form'+Instance.modelName).getForm().getValues();
            for (var source in sourceByDestinationFields) {
                var destination = sourceByDestinationFields[source];
                initData[destination]=formData[source];
            }
            
        }
        Instance.processForms[processName].show(null, function() {});
        var processForm= Instance.processForms[processName].child('#form'+processName+'Process');
        processForm.getForm().reset();
        processForm.getForm().setValues(initData);
    };
    
    function ${labelField}EntityRender(value, p, record){
        if(record){
            if(Instance.typeView==="Parent"){
                return "<a style='font-size: 15px;' href='#?id="+record.data.id+"&tab=1'>"+value+"</a>";
            }else{
                return value;
            }
        }else{
            return value;
        }
    };
    
    Instance.hideParentField= function(entityRef){
        if(Instance.formContainer!==null){
            var fieldsForm= Instance.formContainer.child('#form'+Instance.modelName).items.items;
            fieldsForm.forEach(function(field) {
                if(field.name===entityRef){
                    field.hidden= true;
                }
            });
        }
        if(Instance.gridContainer!==null){
            var columnsGrid= Instance.gridContainer.child('#grid'+Instance.modelName).columns;
            columnsGrid.forEach(function(column) {
                if(column.dataIndex===entityRef){
                    column.hidden= true;
                }
            });
        }
    };
    
    Instance.createMainView= function(){
        <c:forEach var="associatedER" items="${interfacesEntityRef}">
            <c:set var="associatedEntityName" value="${fn:toUpperCase(fn:substring(associatedER, 0, 1))}${fn:substring(associatedER, 1,fn:length(associatedER))}"></c:set>
            <c:set var="associatedEntityTitle" value="${titledFieldsMap[associatedER]}"></c:set>
        Instance.${associatedER}ExtInterfaces= new ${associatedEntityName}ExtInterfaces(parentExtController, Instance);
        Instance.formCombobox${associatedEntityName}= Instance.${associatedER}ExtInterfaces.getCombobox('form', '${entityName}', '${associatedER}', '${associatedEntityTitle}');
        Instance.gridCombobox${associatedEntityName}= Instance.${associatedER}ExtInterfaces.getCombobox('grid', '${entityName}', '${associatedER}', '${associatedEntityTitle}');
        Instance.filterCombobox${associatedEntityName}= Instance.${associatedER}ExtInterfaces.getCombobox('filter', '${entityName}', '${associatedER}', '${associatedEntityTitle}');
        Instance.combobox${associatedEntityName}Render= Instance.${associatedER}ExtInterfaces.getComboboxRender('grid');
        </c:forEach>
        
        Instance.entityDependency= {};
        <c:forEach var="entry" items="${viewConfig.comboboxChildDependent}">
            <c:set var="parentEntityName" value="${fn:toUpperCase(fn:substring(entry.key, 0, 1))}${fn:substring(entry.key, 1,fn:length(entry.key))}"></c:set>
            <c:forEach var="childEntityRef" items="${entry.value}">
                <c:set var="childEntityName" value="${fn:toUpperCase(fn:substring(childEntityRef, 0, 1))}${fn:substring(childEntityRef, 1,fn:length(childEntityRef))}"></c:set>
        Instance.entityDependency["${childEntityRef}"]="${entry.key}";
        Instance.formCombobox${parentEntityName}.comboboxDependent.push(Instance.formCombobox${childEntityName});
        Instance.formCombobox${parentEntityName}.comboboxDependent.push(Instance.gridCombobox${childEntityName});
        
        Instance.gridCombobox${parentEntityName}.comboboxDependent.push(Instance.formCombobox${childEntityName});
        Instance.gridCombobox${parentEntityName}.comboboxDependent.push(Instance.gridCombobox${childEntityName});
        
        Instance.filterCombobox${parentEntityName}.comboboxDependent.push(Instance.filterCombobox${childEntityName});
            </c:forEach>
        </c:forEach>
        
        Instance.childExtControllers= [];
        
        if(Instance.typeView==="Parent"){
        <c:forEach var="childExtViewER" items="${viewsChildEntityRef}">
            <c:set var="childExtViewEN" value="${fn:toUpperCase(fn:substring(childExtViewER, 0, 1))}${fn:substring(childExtViewER, 1,fn:length(childExtViewER))}"></c:set>
            var ${childExtViewER}ExtController= new ${childExtViewEN}ExtController(parentExtController, Instance);
            ${childExtViewER}ExtController.entityExtView.hideParentField("${entityRef}");
            Instance.childExtControllers.push(${childExtViewER}ExtController);
        </c:forEach>
        }
        
        Instance.formContainer= null;
        <c:if test="${viewConfig.visibleForm}">
        Instance.formContainer = getFormContainer(Instance.modelName, Instance.store, Instance.childExtControllers);
        Instance.store.formContainer= Instance.formContainer;
        </c:if>
        
        <c:if test="${viewConfig.visibleGrid}">
        Instance.gridContainer = getGridContainer(Instance.modelName, Instance.store, Instance.formContainer);
        Instance.store.gridContainer= Instance.gridContainer;
        </c:if>
            
        <c:if test="${viewConfig.activeNNMulticheckChild}">
        Instance.checkboxGroupContainer= getCheckboxGroupContainer();
        </c:if>
        
        Instance.processForms={};
        <c:forEach var="processButton" items="${viewConfig.processButtons}">
        Instance.processForms["${processButton.processName}"]= getForm${processButton.processName}Process();
        </c:forEach>
        
        Instance.propertyGrid= getPropertyGrid();

        Instance.tabsContainer= Ext.widget('tabpanel', {
            region: 'center',
            activeTab: 0,
            style: 'background-color:#dfe8f6; margin:0px',
            defaults: {bodyStyle: 'padding:15px', autoScroll:true},
            items:[
                <c:if test="${viewConfig.visibleGrid}">
                Instance.gridContainer,
                </c:if>
                <c:if test="${viewConfig.visibleForm}">
                Instance.formContainer
                </c:if>
            ],
            listeners: {
                tabchange: function(tabPanel, tab){
                    var idx = tabPanel.items.indexOf(tab);
                    var url= util.addUrlParameter(parentExtController.request,"tab", idx);
                    if(idx===0){
                        url= "?tab=0";
                    }
                    if(url!==""){
                        mvcExt.navigate(url);
                    }
                }
            }
        });
        
        Instance.mainView= {
            id: Instance.id,
            title: 'Gestionar ${viewConfig.pluralEntityTitle}',
            frame: false,
            layout: 'border',
            items: [
                Instance.propertyGrid,
                Instance.tabsContainer
            ]
        };
        
    };
    
    Instance.getMainView= function(){
        return Instance.mainView;
    };

    Instance.init();
}
</script>