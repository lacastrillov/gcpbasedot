<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<script>

function ${entityName}ExtController(parentExtController, parentExtView){
    
    var Instance= this;
    
    Instance.id= "/${entityRef}";
    
    Instance.modelName="${entityName}Model";
    
    Instance.services= {};
    
    var util= new Util();
    
    // VIEWS *******************************************
    
    Instance.entityExtView= new ${entityName}ExtView(Instance, null);
    
    //*******************************************************
    
    
    Instance.init= function(){
        Instance.entityRef= "${entityRef}";
        Instance.typeController= "${typeController}";
        mvcExt.mappingController(Instance.id, Instance);
        Instance.initFilter();
        Instance.filter.isn=["webEntity"];
    };
    
    Instance.initFilter= function(){
        Instance.filter={};
    };
    
    Instance.services.index= function(request){
        var activeTab= util.getParameter(request,"tab");
        var filter= util.getParameter(request,"filter");
        var id= util.getParameter(request,"id");
        
        if(activeTab!==null){
            Instance.entityExtView.tabsContainer.setActiveTab(Number(activeTab));
        }else{
            Instance.entityExtView.tabsContainer.setActiveTab(0);
        }
        
        if(filter!==null){
            Instance.initFilter();
            var currentFilter= JSON.parse(filter);
            for (var key in currentFilter) {
                Instance.filter[key]= currentFilter[key];
            }
        }
        
        if(activeTab!=="1"){
            <c:forEach var="associatedER" items="${interfacesEntityRef}">
                <c:set var="associatedEntityName" value="${fn:toUpperCase(fn:substring(associatedER, 0, 1))}${fn:substring(associatedER, 1,fn:length(associatedER))}"></c:set>
            if('eq' in Instance.filter && Instance.filter.eq!==undefined && Instance.filter.eq.${associatedER}!==undefined && Instance.filter.eq.${associatedER}!==''){
                Instance.entityExtView.${associatedER}ExtInterfaces.entityExtStore.load(Instance.filter.eq.${associatedER}, Instance.entityExtView.${associatedER}ExtInterfaces.addLevel);
            }else{
                Instance.entityExtView.${associatedER}ExtInterfaces.addLevel(null);
            }
            </c:forEach>
        }
        
        if(Instance.entityExtView.store.totalCount===undefined && activeTab!=="1"){
            Instance.loadGridData();
        }
        if(activeTab==="1"){
            Instance.loadFormData(id);
        }
    };
    
    Instance.loadGridData= function(){
        Instance.entityExtView.setFilterStore(JSON.stringify(Instance.filter));
        Instance.entityExtView.reloadPageStore(1);
        if(Instance.entityExtView.formComponent!==null){
            Instance.entityExtView.formComponent.setActiveRecord(null);
            util.setHtml("webEntityDetail-innerCt", Instance.entityExtView.commonExtView.getLoadingContent());
        }
    };
    
    Instance.loadFormData= function(id){
        if(Instance.entityExtView.formComponent!==null){
            if(id!==null && id!==""){
                Instance.idEntitySelected= id;
                var activeRecord= Instance.entityExtView.formComponent.getActiveRecord();

                if(activeRecord===null){
                    Instance.entityExtView.entityExtStore.load(id, function(data){
                        var record= Ext.create(Instance.modelName);
                        record.data= data;
                        Instance.entityExtView.formComponent.setActiveRecord(record || null);
                        Instance.entityExtView.webEntityExtInterfaces.addLevel(data);
                        
                        //Cargar entidad
                        var htmlView= '<div style="margin:0px;text-align: center; height: 99%;">'+
                                      '<iframe src="'+data.location+'" frameborder="0" width="100%" height="100%"></iframe>'+
                                      '</div>';
                        util.setHtml("webEntityDetail-innerCt", htmlView);
                    });
                }
            }else{
                Instance.idEntitySelected= "";
                if('eq' in Instance.filter && Object.keys(Instance.filter.eq).length !== 0){
                    var record= Ext.create(Instance.modelName);
                    for (var key in Instance.filter.eq) {
                        record.data[key]= Instance.filter.eq[key];
                    }
                    Instance.entityExtView.formComponent.setActiveRecord(record || null);
                }
            }
        }
    };
    
    Instance.formSavedResponse= function(responseText){
        if(responseText.success && false){
            <c:if test="${viewConfig.multipartFormData}">
            Instance.entityExtView.entityExtStore.upload(Instance.entityExtView.formComponent, responseText.data.id, function(responseUpload){
                Ext.MessageBox.alert('Status', responseText.message+"<br>"+responseUpload.message);
                if(responseUpload.success){
                    var record= Ext.create(Instance.modelName);
                    record.data= responseUpload.data;
                    Instance.entityExtView.formComponent.setActiveRecord(record || null);
                }
            });
            </c:if>
        }else{
            Ext.MessageBox.alert('Status', responseText.message);
        }
    };
    
    Instance.getSelectedIds= function(){
        var selection = Instance.entityExtView.gridComponent.getSelectionModel().getSelection();
        var ids=[];
        if (selection.length>0) {
            for(var i=0; i<selection.length; i++){
                ids.push(selection[i].data.id);
            }
        }else{
            var check_items= document.getElementsByClassName("item_check");
            for(var i=0; i<check_items.length; i++){
                if(check_items[i].checked){
                    ids.push(check_items[i].value);
                }
            }
        }
        return ids;
    };
    
    Instance.deleteRecords= function(){
        var ids= Instance.getSelectedIds();
        if(ids.length>0){
            var filter={"in":{"id":ids}};
            if(ids.length===1){
                Instance.entityExtView.entityExtStore.deleteByFilter(JSON.stringify(filter), function(responseText){
                    Instance.loadFormData("");
                    Instance.entityExtView.reloadPageStore(Instance.entityExtView.store.currentPage);
                });
            }else{
                Ext.MessageBox.confirm('Confirmar', 'Esta seguro que desea eliminar '+ids.length+' registros?', function(result){
                    if(result==="yes"){
                        Instance.entityExtView.entityExtStore.deleteByFilter(JSON.stringify(filter), function(responseText){
                            Instance.loadFormData("");
                            Instance.entityExtView.reloadPageStore(Instance.entityExtView.store.currentPage);
                        });
                    }
                });
            }
        }
    };
    
    Instance.doFilter= function(filter){
        var url= "?filter="+JSON.stringify(filter);
        Instance.reloadGrid= true;
        console.log(url);
        mvcExt.navigate(url);
    };
    
    Instance.viewInternalPage= function(path){
        var urlAction= path;
        if(Instance.idEntitySelected!==""){
            urlAction+='#?filter={"eq":{"${entityRef}":'+Instance.idEntitySelected+'}}';
        }
        mvcExt.redirect(urlAction);
    };

    Instance.init();
}
</script>
