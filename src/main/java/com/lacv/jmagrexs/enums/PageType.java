/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package com.lacv.jmagrexs.enums;

/**
 *
 * @author lacastrillov
 */
public enum PageType {
    
    ENTITY("entity"),
    
    ENTITY_FORM("entityForm"),
    
    REPORT("report"),
    
    PROCESS("process"),
    
    FILE_EXPLORER("fileExplorer"),
    
    ENTITY_EXPLORER("entityExplorer"),
    
    CONFIGURATION_OBJECT("configurationObject");
    
    
    private final String pageRef;
    
    PageType(String pageRef){
        this.pageRef= pageRef;
    }

    public String getPageRef(){
        return this.pageRef;
    }
}
