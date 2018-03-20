/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package com.dot.gcpbasedot.service;

import com.dot.gcpbasedot.annotation.HttpHeader;
import com.dot.gcpbasedot.annotation.PathVar;
import com.dot.gcpbasedot.dto.RESTServiceDto;
import com.dot.gcpbasedot.dto.SOAPServiceDto;
import com.dot.gcpbasedot.reflection.EntityReflection;
import com.dot.gcpbasedot.util.RESTServiceConnection;
import com.dot.gcpbasedot.util.FileService;
import com.dot.gcpbasedot.util.SimpleSOAPClient;
import com.dot.gcpbasedot.util.Util;
import java.io.IOException;
import java.io.InputStream;
import java.lang.reflect.Field;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import javax.xml.soap.SOAPException;
import org.apache.log4j.Logger;
import org.json.JSONObject;

/**
 *
 * @author grupot
 */
public abstract class ExternalServiceImpl implements ExternalService {
    
    protected static final Logger LOGGER = Logger.getLogger(ExternalServiceImpl.class);
    
    protected final Map<String, RESTServiceConnection> restServiceConnections = new HashMap<>();
    
    protected final Map<String, SimpleSOAPClient> simpleSOAPClients = new HashMap<>();
    
    protected Map<String, String> envelopeMap= new HashMap<>();
    
    protected final Map<String, Class> inDtos = new HashMap<>();

    protected final Map<String, Class> outDtos = new HashMap<>();
    
    private String baseEnvelopeFile;
    
    
    protected void enableRESTService(RESTServiceDto restService){
        RESTServiceConnection restServiceConnection= new RESTServiceConnection(restService);
        restServiceConnections.put(restService.getProcessName(), restServiceConnection);
        inDtos.put(restService.getProcessName(), restService.getInClass());
        outDtos.put(restService.getProcessName(), restService.getOutClass());
    }
    
    protected void enableSOAPClient(SOAPServiceDto soapService){
        SimpleSOAPClient simpleSOATClient= new SimpleSOAPClient(soapService);
        simpleSOAPClients.put(soapService.getProcessName(), simpleSOATClient);
        inDtos.put(soapService.getProcessName(), soapService.getInClass());
    }
    
    @Override
    public boolean isRESTService(String processName){
        return restServiceConnections.containsKey(processName);
    }
    
    @Override
    public boolean isSOAPService(String processName){
        return simpleSOAPClients.containsKey(processName);
    }
    
    @Override
    public RESTServiceDto getRESTService(String processName){
        if(isRESTService(processName)){
            return restServiceConnections.get(processName).getRESTService();
        }
        return null;
    }
    
    @Override
    public SOAPServiceDto getSOAPService(String processName){
        if(isSOAPService(processName)){
            return simpleSOAPClients.get(processName).getSoapService();
        }
        return null;
    }
    
    public void setBaseEnvelopeFile(String baseEnvelopeFile){
        this.baseEnvelopeFile= baseEnvelopeFile;
    }
    
    @Override
    public Object callService(String processName, Object data){
        try{
            if(isRESTService(processName)){
                return callRESTService(processName, data);
            }else if(isSOAPService(processName)){
                return callSOAPService(processName, data);
            }
        }catch(IOException | SOAPException e){
            LOGGER.error("ERROR callService "+processName, e);
        }
        return null;
    }
    
    @Override
    public Object callRESTService(String processName, Object data) throws IOException {
        RESTServiceConnection restServiceConnection= restServiceConnections.get(processName);
        RESTServiceDto externalService= restServiceConnection.getRESTService();
        JSONObject jsonData= new JSONObject(Util.objectToJson(data));
        
        Map<String, String> headers= null;
        Map<String, String> pathVars= null;
        Map<String, String> parameters= null;
        Object body= null;
        
        //Headers
        List<Field> headerFields= EntityReflection.getEntityAnnotatedFields(externalService.getInClass(), HttpHeader.class);
        if(headerFields.size()>0){
            headers= new HashMap<>();
            for(Field field: headerFields){
                HttpHeader an= field.getAnnotation(HttpHeader.class);
                headers.put(an.value(), jsonData.get(field.getName()).toString());
                jsonData.remove(field.getName());
            }
        }
        
        //Path Vars
        List<Field> pathVarFields= EntityReflection.getEntityAnnotatedFields(externalService.getInClass(), PathVar.class);
        if(pathVarFields.size()>0){
            pathVars= new HashMap<>();
            for(Field field: pathVarFields){
                pathVars.put(field.getName(), jsonData.get(field.getName()).toString());
                jsonData.remove(field.getName());
            }
        }
        
        if(jsonData.names()!=null && jsonData.names().length()>0){
            if(externalService.getModeSendingData().equals(RESTServiceDto.IN_BODY)){
                body= EntityReflection.jsonToObject(jsonData.toString(), externalService.getInClass());
            }else if(externalService.getModeSendingData().equals(RESTServiceDto.IN_PARAMETERS)){
                parameters= new HashMap<>();
                for(int i = 0; i<jsonData.names().length(); i++){
                    String fieldName= jsonData.names().getString(i);
                    parameters.put(fieldName, jsonData.get(fieldName).toString());
                }
            }
        }
        
        return restServiceConnection.getObjectResult(headers, pathVars, parameters, body);
    }
    
    @Override
    public String callSOAPService(String processName, Object data) throws SOAPException, IOException{
        SimpleSOAPClient simpleSOAPClient= simpleSOAPClients.get(processName);
        JSONObject jsonData= new JSONObject(Util.objectToJson(data));
        String xmlRequestBody= null;
        if(!envelopeMap.containsKey(processName)){
            if(baseEnvelopeFile==null){
                baseEnvelopeFile= this.getClass().getSimpleName();
            }
            InputStream is= this.getClass().getClassLoader().getResourceAsStream("soap_envelopes/"+baseEnvelopeFile+"-"+processName+".xml");
            envelopeMap.put(processName, FileService.getStringFromInputStream(is));
            xmlRequestBody= envelopeMap.get(processName);
        }
        xmlRequestBody= simpleSOAPClient.mergeDataInEnvelope(jsonData, envelopeMap.get(processName));
        String jsonOut= simpleSOAPClient.sendMessageGetJSON(xmlRequestBody).toString();
        
        return jsonOut;
    }
    
}