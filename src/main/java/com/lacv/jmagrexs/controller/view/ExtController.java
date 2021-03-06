/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package com.lacv.jmagrexs.controller.view;

import com.lacv.jmagrexs.components.ExtViewConfig;
import com.lacv.jmagrexs.components.FieldConfigurationByAnnotations;
import com.lacv.jmagrexs.components.JSONColumns;
import com.lacv.jmagrexs.components.JSONEntityFields;
import com.lacv.jmagrexs.components.JSONFilters;
import com.lacv.jmagrexs.components.JSONForms;
import com.lacv.jmagrexs.components.JSONModels;
import com.lacv.jmagrexs.components.MenuComponent;
import com.lacv.jmagrexs.components.RangeFunctions;
import com.lacv.jmagrexs.components.ServerDomain;
import com.lacv.jmagrexs.dto.MenuItem;
import java.util.List;
import javax.servlet.http.HttpSession;
import org.json.JSONArray;
import org.json.JSONObject;
import org.springframework.beans.factory.annotation.Autowired;

/**
 *
 * @author lacastrillov
 */
public abstract class ExtController {
    
    @Autowired
    public ExtViewConfig extViewConfig;
    
    @Autowired
    public MenuComponent menuComponent;
    
    @Autowired
    public ServerDomain serverDomain;
    
    @Autowired
    public FieldConfigurationByAnnotations fcba;
    
    @Autowired
    public RangeFunctions rf;
    
    @Autowired
    public JSONModels jm;
    
    @Autowired
    public JSONFilters jf;
    
    @Autowired
    public JSONForms jfo;
    
    @Autowired
    public JSONEntityFields jfef;
    
    @Autowired
    public JSONColumns jc;
    
    
    public JSONArray getMenuItems(HttpSession session, MenuComponent globalMenuComponent){
        JSONArray menuJSON;
        if(session.getAttribute("menuItems")==null){
            List<MenuItem> menuData= globalMenuComponent.getMenuData();
            menuData= configureVisibilityMenu(menuData);
            menuJSON= generateMenuJSON(menuData);
            session.setAttribute("menuItems", menuJSON.toString());
        }else{
            menuJSON= new JSONArray((String)session.getAttribute("menuItems"));
        }
        
        return menuJSON;
    }
    
    private JSONArray generateMenuJSON(List<MenuItem> menuItems){
        JSONArray menuJSON= new JSONArray();
        for (MenuItem menuDataI : menuItems) {
            if(menuDataI.isVisible()){
                JSONObject menuParent= new JSONObject();
                MenuItem itemParent = menuDataI;
                menuParent.put("text", itemParent.getItemTitle());
                if(menuDataI.getType().equals(MenuItem.CHILD)){
                    menuParent.put("href", itemParent.getHref());
                }
                if(itemParent.getSubMenus().size()>0){
                    JSONObject menu= new JSONObject();
                    JSONArray items= generateMenuJSON(itemParent.getSubMenus());
                    menu.put("items", items);
                    menuParent.put("menu", menu);
                }
                menuJSON.put(menuParent);
            }
        }
        return menuJSON;
    }
    
    protected List<MenuItem> configureVisibilityMenu(List<MenuItem> menuData){
        // ABSTRACT CODE HERE
        return menuData;
    }
    
}
