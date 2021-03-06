/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package com.lacv.jmagrexs.components;

import com.lacv.jmagrexs.enums.FieldType;
import java.util.HashMap;
import java.util.LinkedHashMap;
import org.json.JSONArray;
import org.json.JSONObject;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;

/**
 *
 * @author e11001a
 */
@Component
public class JSONEntityFields {
    
    @Autowired
    public ExtViewConfig extViewConfig;
    
    public void addJSONField(JSONArray jsonFormFields, String entityName, String type, String fieldName,
            String fieldTitle, String titleGroup, HashMap<String,String[]> typeFormFields, HashMap<String, Integer[]> sizeColumnMap, 
            LinkedHashMap<String,JSONObject> fieldGroups, HashMap<String, Integer> positionColumnForm, int numColumnsForm,
            boolean isEditableForm, boolean readOnly, boolean fieldNN){
        
        boolean addField= true;
        boolean visible= true;
        JSONObject formField= new JSONObject();
        formField.put("id", entityName + "_" +fieldName);
        formField.put("name", fieldName);
        formField.put("fieldLabel", fieldTitle);
        formField.put("allowBlank", !fieldNN);

        JSONObject rendererField= new JSONObject();
        rendererField.put("id", entityName + "_" + fieldName + "Renderer");
        rendererField.put("name", fieldName);
        rendererField.put("fieldLabel", fieldTitle);
        rendererField.put("xtype", "displayfield");

        if(!isEditableForm || readOnly){
            formField.put("readOnly", true);
        }
        if(typeFormFields.containsKey(fieldName)){
            String typeField= typeFormFields.get(fieldName)[0];
            if(typeField.equals(FieldType.EMAIL.name())){
                formField.put("vtype", "email");
            }else if(typeField.equals(FieldType.PASSWORD.name())){
                formField.put("inputType", "password");
            }else if(typeField.equals(FieldType.TEXT_AREA.name())){
                formField.put("xtype", "textarea");
                if(isEditableForm){
                    formField.put("height", 200);
                }
            }else if(typeField.equals(FieldType.DATETIME.name())){
                formField.put("xtype", "datefield");
                formField.put("format", extViewConfig.getDatetimeFormat());
                formField.put("tooltip", "Seleccione la fecha");
                if(!isEditableForm){
                    formField.put("renderer", "@Ext.util.Format.dateRenderer('"+extViewConfig.getDatetimeFormat()+"')@");
                }
            }else if(typeField.equals(FieldType.HTML_EDITOR.name())){
                formField.put("xtype", "htmleditor");
                formField.put("enableColors", true);
                formField.put("enableAlignments", true);
                if(isEditableForm){
                    formField.put("height", 400);
                }
            }else if(typeField.equals(FieldType.LIST.name()) || typeField.equals(FieldType.MULTI_SELECT.name())){
                addField= false;
                String[] data= typeFormFields.get(fieldName);
                JSONArray dataArray = new JSONArray();
                for(int i=1; i<data.length; i++){
                    dataArray.put(data[i]);
                }
                if(!readOnly && isEditableForm){
                    String field= "@Instance.commonExtView.getSimpleCombobox('"+fieldName+"','"+fieldTitle+"','form',"+dataArray.toString().replaceAll("\"", "'")+","+(!fieldNN)+")@";
                    addFormField(field,jsonFormFields,numColumnsForm,titleGroup,fieldGroups,positionColumnForm,visible);
                }else{
                    addField=true;
                }
            }else if(typeField.equals(FieldType.RADIOS.name())){
                addField= false;
                String[] data= typeFormFields.get(fieldName);
                JSONArray dataArray = new JSONArray();
                for(int i=1; i<data.length; i++){
                    dataArray.put(data[i]);
                }
                String field= "@Instance.commonExtView.getRadioGroup('"+fieldName+"','"+fieldTitle+"',"+dataArray.toString().replaceAll("\"", "'")+")@";
                addFormField(field,jsonFormFields,numColumnsForm,titleGroup,fieldGroups,positionColumnForm,visible);
            }else if(typeField.equals(FieldType.FILE_SIZE.name())){
                formField.put("xtype", "numberfield");
                formField.put("fieldLabel", fieldTitle+" (bytes)");

                //Add file Size Text
                rendererField.put("renderer", "@Instance.commonExtView.fileSizeRender@");
                jsonFormFields.put(rendererField);
                if(!isEditableForm){
                    addField= false;
                }
            }else if(typeField.equals(FieldType.PERCENTAJE.name())){
                formField.put("xtype", "numberfield");
                formField.put("fieldLabel", fieldTitle+" (%)");
                formField.put("minValue", 0);
                formField.put("maxValue", 100);
            }else if(typeField.equals(FieldType.COLOR.name())){
                formField.put("xtype", "customcolorpicker");
            }else if(typeField.equals(FieldType.ON_OFF.name())){
                formField.put("xtype", "checkbox");
                formField.put("inputValue", "true");
                formField.put("uncheckedValue", "false");
                formField.put("cls", "hidden");
                
                //Add Button ON/OFF
                rendererField.put("renderer", "@Instance.commonExtView.onOffRender@");
                addFormField(rendererField,jsonFormFields,numColumnsForm,titleGroup,fieldGroups,positionColumnForm,visible);
                visible= false;
            }else if(typeField.equals(FieldType.VIDEO_YOUTUBE.name())){
                formField.put("fieldLabel", "Link "+fieldTitle);
                formField.put("emptyText", "Url Youtube");

                //Add Video Youtube
                rendererField.put("renderer", "@Instance.commonExtView.videoYoutubeRender@");
                addFormField(rendererField,jsonFormFields,numColumnsForm,titleGroup,fieldGroups,positionColumnForm,visible);
            }else if(typeField.equals(FieldType.GOOGLE_MAP.name())){
                formField.put("fieldLabel", "Coordenadas "+fieldTitle);
                formField.put("emptyText", "Google Maps Point");

                //Add GoogleMap
                rendererField.put("renderer", "@Instance.commonExtView.googleMapsRender@");
                addFormField(rendererField,jsonFormFields,numColumnsForm,titleGroup,fieldGroups,positionColumnForm,visible);
            }else if(typeField.equals(FieldType.FILE_UPLOAD.name())){
                formField.put("name", fieldName + "_File");
                formField.put("xtype", "filefield");
                formField.put("fieldLabel", "Subir "+fieldTitle);
                formField.put("emptyText", "Seleccione un archivo");

                //Add Url File
                rendererField.put("renderer", "@Instance.commonExtView.fileRender@");
                addFormField(rendererField,jsonFormFields,numColumnsForm,titleGroup,fieldGroups,positionColumnForm,visible);
                if(!isEditableForm){
                    addField= false;
                }
            }else if(typeField.equals(FieldType.IMAGE_FILE_UPLOAD.name())){
                formField.put("name", fieldName + "_File");
                formField.put("xtype", "filefield");
                formField.put("fieldLabel", "Subir "+fieldTitle);
                formField.put("emptyText", "Seleccione una imagen");

                //Add Image
                rendererField.put("renderer", "@Instance.commonExtView.imageRender@");
                addFormField(rendererField,jsonFormFields,numColumnsForm,titleGroup,fieldGroups,positionColumnForm,visible);
                if(!isEditableForm){
                    addField= false;
                }
            }else if(typeField.equals(FieldType.VIDEO_FILE_UPLOAD.name())){
                formField.put("name", fieldName + "_File");
                formField.put("xtype", "filefield");
                formField.put("fieldLabel", "Subir "+fieldTitle);
                formField.put("emptyText", "Seleccione un video");

                //Add Video
                rendererField.put("renderer", "@Instance.commonExtView.videoFileUploadRender@");
                addFormField(rendererField,jsonFormFields,numColumnsForm,titleGroup,fieldGroups,positionColumnForm,visible);
                if(!isEditableForm){
                    addField= false;
                }
            }else if(typeField.equals(FieldType.AUDIO_FILE_UPLOAD.name())){
                formField.put("name", fieldName + "_File");
                formField.put("xtype", "filefield");
                formField.put("fieldLabel", "Subir "+fieldTitle);
                formField.put("emptyText", "Seleccione un audio");

                //Add Audio
                rendererField.put("renderer", "@Instance.commonExtView.audioFileUploadRender@");
                addFormField(rendererField,jsonFormFields,numColumnsForm,titleGroup,fieldGroups,positionColumnForm,visible);
                if(!isEditableForm){
                    addField= false;
                }
            }else if(typeField.equals(FieldType.MULTI_FILE_TYPE.name())){
                formField.put("name", fieldName + "_File");
                formField.put("xtype", "filefield");
                formField.put("fieldLabel", "Subir "+fieldTitle);
                formField.put("emptyText", "Seleccione un archivo");

                //Add MultiFile
                rendererField.put("renderer", "@Instance.commonExtView.multiFileRender@");
                addFormField(rendererField,jsonFormFields,numColumnsForm,titleGroup,fieldGroups,positionColumnForm,visible);
                if(!isEditableForm){
                    addField= false;
                }
            }
            if(typeField.equals(FieldType.FILE_UPLOAD.name()) || typeField.equals(FieldType.IMAGE_FILE_UPLOAD.name()) ||
                    typeField.equals(FieldType.VIDEO_FILE_UPLOAD.name()) || typeField.equals(FieldType.AUDIO_FILE_UPLOAD.name()) ||
                    typeField.equals(FieldType.MULTI_FILE_TYPE.name())){

                formField.put("allowBlank", true);
                //Add link Field
                JSONObject linkField= new JSONObject();
                linkField.put("id", entityName+"_"+fieldName + "Link");
                linkField.put("name", fieldName);
                linkField.put("fieldLabel", "Link "+fieldTitle);
                linkField.put("allowBlank", !fieldNN);
                linkField.put("readOnly", readOnly);
                if(!isEditableForm){
                    linkField.put("xtype", "displayfield");
                }
                addFormField(linkField,jsonFormFields,numColumnsForm,titleGroup,fieldGroups,positionColumnForm,visible);
            }
        }else{
            switch (type) {
                case "java.util.Date":
                    formField.put("xtype", "datefield");
                    formField.put("format", extViewConfig.getDateFormat());
                    formField.put("altFormats", extViewConfig.getDatetimeFormat());
                    formField.put("tooltip", "Seleccione la fecha");
                    if(!isEditableForm){
                        formField.put("renderer", "@Ext.util.Format.dateRenderer('"+extViewConfig.getDateFormat()+"')@");
                    }
                    break;
                case "java.sql.Time":
                    formField.put("xtype", "timefield");
                    formField.put("format", extViewConfig.getTimeFormat());
                    formField.put("tooltip", "Seleccione la hora");
                    if(!isEditableForm){
                        formField.put("renderer", "@Ext.util.Format.dateRenderer('"+extViewConfig.getTimeFormat()+"')@");
                    }
                    break;
                case "short":
                case "java.lang.Short":
                case "int":
                case "java.lang.Integer":
                case "long":
                case "java.lang.Long":
                case "java.math.BigInteger":
                case "double":
                case "java.lang.Double":
                case "float":
                case "java.lang.Float":
                    formField.put("xtype", "numberfield");
                    break;
                case "boolean":
                case "java.lang.Boolean":
                    formField.put("xtype", "checkbox");
                    formField.put("inputValue", "true");
                    formField.put("uncheckedValue", "false");
                    break;
            }
        }
        if(sizeColumnMap.containsKey(fieldName)){
            formField.put("minLength", sizeColumnMap.get(fieldName)[0]);
            formField.put("maxLength", sizeColumnMap.get(fieldName)[1]);
        }
        if(addField){
            if(!isEditableForm){
                formField.put("xtype", "displayfield");
            }
            addFormField(formField,jsonFormFields,numColumnsForm,titleGroup,fieldGroups,positionColumnForm,visible);
        }
    }
    
    public void addEntityCombobox(JSONArray jsonFormFields, String fieldEntity, boolean isEditableForm, int numColumnsForm,
            String titleGroup, LinkedHashMap<String,JSONObject> fieldGroups, HashMap<String,Integer> positionColumnForm,
            boolean readOnly, boolean fieldNN){
        
        String combobox="(function(){ ";
        if(!isEditableForm || readOnly){
            combobox+="Instance.formCombobox"+fieldEntity+".setDisabled(true); ";
        }
        if(fieldNN){
            combobox+="Instance.formCombobox"+fieldEntity+".allowBlank=false; ";
        }
        combobox+="return Instance.formCombobox"+fieldEntity+";" +
                        "})()";
        addFormField("@"+combobox+"@",jsonFormFields,numColumnsForm,titleGroup,fieldGroups,positionColumnForm,true);
    }
    
    private void addFormField(Object field, JSONArray jsonFormFields, int numColumnsForm, String titleGroup,
            LinkedHashMap<String,JSONObject> fieldGroups, HashMap<String,Integer> positionColumnForm, boolean visible){
        
        if(numColumnsForm<=1){
            if(titleGroup.equals("")){
                jsonFormFields.put(field);
            }else{
                fieldGroups.get(titleGroup).getJSONArray("items").put(field);
            }
        }else{ 
            if((positionColumnForm.get(titleGroup)==0 || positionColumnForm.get(titleGroup)==numColumnsForm) && visible){
                JSONObject defaults= new JSONObject();
                double columnWidth= (double)1/numColumnsForm-0.02;
                defaults.put("columnWidth", (double)Math.round(columnWidth * 100d) / 100d);
                defaults.put("margin", 7);
                
                JSONObject objectColumn= new JSONObject();
                objectColumn.put("xtype", "container");
                objectColumn.put("layout", "column");
                objectColumn.put("defaultType", "textfield");
                objectColumn.put("defaults", defaults);
                objectColumn.put("items", new JSONArray());
                if(titleGroup.equals("")){
                    jsonFormFields.put(objectColumn);
                }else{
                    fieldGroups.get(titleGroup).getJSONArray("items").put(objectColumn);
                }
                if(positionColumnForm.get(titleGroup)==numColumnsForm){
                    positionColumnForm.put(titleGroup,0);
                }
            }
            if(positionColumnForm.get(titleGroup) < numColumnsForm || !visible){
                if(titleGroup.equals("")){
                    int index= jsonFormFields.length()-1;
                    jsonFormFields.getJSONObject(index).getJSONArray("items").put(field);
                }else{
                    int index= fieldGroups.get(titleGroup).getJSONArray("items").length()-1;
                    fieldGroups.get(titleGroup).getJSONArray("items").getJSONObject(index).getJSONArray("items").put(field);
                }
            }
            if(visible){
                positionColumnForm.put(titleGroup,positionColumnForm.get(titleGroup)+1);
            }
        }
    }
    
}
