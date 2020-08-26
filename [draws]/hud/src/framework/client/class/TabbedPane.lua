local super = Class("TabbedPane", Panel, function()
	static.WRAP_TAB_LAYOUT = 0
    static.SCROLL_TAB_LAYOUT = 1
	static.uiClassID = "TabbedPaneUI"

	static.Page = Class("TabbedPane.Page", LuaObject)
	static.Button = Class("TabbedPane.Button", Button)

end).getSuperclass()

function TabbedPane:init(tabPlacement, tabLayoutPolicy)
	super.init(self)
    self.tabPlacement = UIConstants.TOP
    self.tabLayoutPolicy = nil
    self.model = nil
    self.haveRegistered = nil
	self.changeListener = nil
	self.pages = ArrayList("table")
    self.visComp = nil
    self.changeEvent = nil
	self.contentPane = Panel()	
	self.contentPane:setBackground(tocolor(200,0,0))
	super.add(self, self.contentPane)
	self:setTabPlacement(tabPlacement or UIConstants.TOP)
	self:setTabLayoutPolicy(tabLayoutPolicy or TabbedPane.WRAP_TAB_LAYOUT)
    self:setModel(DefaultSingleSelectionModel())
    self:updateUI()	
	
	return self
end

function TabbedPane:paintComponent(g)
	
	for k,v in pairs(self.pages.table) do
		--outputDebugString(v.name)
	end

	super.paintComponent(self, g)
end

--[[
    public TabbedPaneUI getUI()
        return (TabbedPaneUI)ui;
    end


    public void setUI(TabbedPaneUI ui)
        super.setUI(ui);

        for (int i = 0; i < getTabCount(); i++)
            Icon icon = pages.get(i).disabledIcon;
            if (icon instanceof UIResource)
                setDisabledIconAt(i, nil);
            end
        end
    end
]]

function TabbedPane:updateUI()
    --setUI((TabbedPaneUI)UIManager.getUI(this));
	self.contentPane:setBounds(0,30,self:getWidth(),self:getHeight()-30)
end

function TabbedPane:getUIClassID()
    return self.uiClassID
end

function TabbedPane:createChangeListener()
	return {
		name = "ChangeListener",
		stateChanged = function(e)
            self:fireStateChanged()
        end
	}
end
	
function TabbedPane:addChangeListener(l)
	self.listenerList:add(ChangeListener, l)
end

function TabbedPane:removeChangeListener(l)
	self.listenerList:remove(ChangeListener, l)
end

function TabbedPane:fireStateChanged()

	local selIndex = self:getSelectedIndex()
	
	if (selIndex < 0) then
		if (self.visComp ~= nil and self.visComp:isVisible()) then
			self.visComp:setVisible(false);
		end
		self.visComp = nil
	else
		local newComp = self:getComponentAt(selIndex)

		if (newComp ~= nil and newComp ~= self.visComp) then
			local shouldChangeFocus = false

			if (self.visComp ~= nil) then
				shouldChangeFocus = Utilities.findFocusOwner(self.visComp) ~= nil
				if (self.visComp.isVisible()) then
					self.visComp.setVisible(false)
				end
			end

			if (not newComp:isVisible()) then
				newComp:setVisible(true)
			end

			if (shouldChangeFocus) then
				Utilities.tabbedPaneChangeFocusTo(newComp)
			end

			self.visComp = newComp;
		end 
	end

	if (self.changeListener) then
		if (self.changeEvent == nil) then
			self.changeEvent = ChangeEvent(self)
		end
		self.changeListener:stateChanged(self.changeEvent)
	end
end
   
function TabbedPane:getModel()
	return self.model
end


function TabbedPane:setModel(model)
	local oldModel = self:getModel()

	if (oldModel ~= nil) then
		oldModel:removeChangeListener(self.changeListener)
		self.changeListener = nil
	end

	self.model = model

	if (model ~= nil) then
		self.changeListener = self:createChangeListener()
		model:addChangeListener(self.changeListener)
	end

	self:firePropertyChange("model", oldModel, model)
	self:repaint()
end

function TabbedPane:getTabPlacement()
	return self.tabPlacement;
end

function TabbedPane:setTabPlacement(tabPlacement)
	if (tabPlacement ~= UIConstants.TOP and tabPlacement ~= UIConstants.LEFT and
		tabPlacement ~= UIConstants.BOTTOM and tabPlacement ~= UIConstants.RIGHT) then
		throw('IllegalArgumentException("illegal tab placement: must be TOP, BOTTOM, LEFT, or RIGHT")');
	end
	if (self.tabPlacement ~= tabPlacement) then
		local oldValue = self.tabPlacement
		self.tabPlacement = tabPlacement
		self:firePropertyChange("tabPlacement", oldValue, tabPlacement)
		self:revalidate()
		self:repaint()
    end
end

   
function TabbedPane:getTabLayoutPolicy()
	return self.tabLayoutPolicy
end


function TabbedPane:setTabLayoutPolicy(tabLayoutPolicy) 
	if (tabLayoutPolicy ~= TabbedPane.WRAP_TAB_LAYOUT and tabLayoutPolicy ~= TabbedPane.SCROLL_TAB_LAYOUT) then
		throw('IllegalArgumentException("illegal tab layout policy: must be WRAP_TAB_LAYOUT or SCROLL_TAB_LAYOUT")')
	end
	if (self.tabLayoutPolicy ~= tabLayoutPolicy) then
		local oldValue = self.tabLayoutPolicy
		self.tabLayoutPolicy = tabLayoutPolicy
		self:firePropertyChange("tabLayoutPolicy", oldValue, tabLayoutPolicy)
		self:revalidate()
		self:repaint()
	end
end


function TabbedPane:getSelectedIndex()
	return self.model:getSelectedIndex()
end

    
function TabbedPane:setSelectedIndex(index)
	if (index ~= -1) then
		self:checkIndex(index)
	end
	self:setSelectedIndexImpl(index, true)
end

function TabbedPane:setSelectedIndexImpl(index, doAccessibleChanges)
	local oldIndex = self.model:getSelectedIndex()
	local oldPage = nil
	local newPage = nil
	local oldName = nil

	doAccessibleChanges = doAccessibleChanges and (oldIndex ~= index)

	if (doAccessibleChanges) then
		if (accessibleContext ~= nil) then
			oldName = accessibleContext.getAccessibleName();
		end

		if (oldIndex >= 0) then
			oldPage = self.pages:get(oldIndex)
		end

		if (index >= 0) then
			newPage = self.pages:get(index)
		end
	end

	self.model:setSelectedIndex(index)

	if (doAccessibleChanges) then
		changeAccessibleSelection(oldPage, oldName, newPage)
	end
end

function TabbedPane:changeAccessibleSelection(oldPage, oldName, newPage)
	if (accessibleContext == nil) then
		return
	end

	if (oldPage ~= nil) then
		oldPage.firePropertyChange(AccessibleContext.ACCESSIBLE_STATE_PROPERTY, AccessibleState.SELECTED, nil)
	end

	if (newPage ~= nil) then
		newPage.firePropertyChange(AccessibleContext.ACCESSIBLE_STATE_PROPERTY, nil, AccessibleState.SELECTED)
	end

	accessibleContext.firePropertyChange(AccessibleContext.ACCESSIBLE_NAME_PROPERTY, oldName, accessibleContext.getAccessibleName())
end

    
function TabbedPane:getSelectedComponent()
	local index = self:getSelectedIndex()
	if (index == -1) then
		return nil
	end
	return self:getComponentAt(index);
end

    
function TabbedPane:setSelectedComponent(c)
	local index = self:indexOfComponent(c)
	if (index ~= -1) then
		self:setSelectedIndex(index)
	else
		throw(IllegalArgumentException("component not found in tabbed pane"));
	end
end

function TabbedPane:insertTab(title, icon, component, tip, index)
	local newIndex = index

	local removeIndex = self:indexOfComponent(component)
	
	if (component ~= nil and removeIndex ~= -1) then
		self:removeTabAt(removeIndex)
		if (newIndex > removeIndex) then
			newIndex = newIndex - 1
		end
	end

	local selectedIndex = self:getSelectedIndex()

	self.pages:add(TabbedPane.Page(self, title or "", icon, nil, component, tip), newIndex)

	if (component ~= nil) then
		self:addImpl(component, nil, -1)
		component:setVisible(false)
	else
		self:firePropertyChange("indexForNullComponent", -1, index);
	end

	if (self.pages:size() == 1) then
		self:setSelectedIndex(0)
	end

	if (selectedIndex >= newIndex) then
		self:setSelectedIndexImpl(selectedIndex + 1, false)
	end

	if (not self.haveRegistered and tip ~= nil) then
		ToolTipManager.sharedInstance():registerComponent(self)
		self.haveRegistered = true
	end

	self:revalidate()
	self:repaint()
end


function TabbedPane:addTab(...)
	if(isAssignableFrom(arg, {"string", "table", "table", "string"})) then
		local title, icon, component, tip = unpack(arg)
		self:insertTab(title, icon, component, tip, self.pages:size())
		return component
	elseif(isAssignableFrom(arg, {"string", "table", "table"})) then
		local title, icon, component = unpack(arg)
		self:insertTab(title, icon, component, nil, self.pages:size())
		return component
	elseif(isAssignableFrom(arg, {"string", "table"})) then
		local title, component = unpack(arg)
		self:insertTab(title, nil, component, nil, self.pages:size())
		return component		
	end
end

function TabbedPane:add(...)
	if(isAssignableFrom(arg, {"table"})) then
		local component = unpack(arg)
		self:addTab(component:getName(), component)
		return component
	elseif(isAssignableFrom(arg, {"string", "table"})) then
		local title, component = unpack(arg)
		self:addTab(title, component)
		return component
	elseif(isAssignableFrom(arg, {"table", "number"})) then
		local component, index = unpack(arg)
		self:insertTab(component:getName(), nil, component, nil, iif(index == -1, self:getTabCount(), index))
		return component		
	end	
end

 --[[  
 
    public void add(Component component, Object constraints)
        if (!(component instanceof UIResource))
            if (constraints instanceof String)
                addTab((String)constraints, component);
            end else if (constraints instanceof Icon)
                addTab(nil, (Icon)constraints, component);
            end else {
                add(component);
            end
        end else {
            super.add(component, constraints);
        end
    end

    
    public void add(Component component, Object constraints, int index)
        if (!(component instanceof UIResource))

            Icon icon = constraints instanceof Icon? (Icon)constraints : nil;
            String title = constraints instanceof String? (String)constraints : nil;

            insertTab(title, icon, component, nil, index == -1? getTabCount() : index);
        end else {
            super.add(component, constraints, index);
        end
    end

    
    public void removeTabAt(int index)
        checkIndex(index);

        Component component = getComponentAt(index);
        boolean shouldChangeFocus = false;
        int selected = getSelectedIndex();
        String oldName = nil;

        
        if (component == visComp)
            shouldChangeFocus = (SwingUtilities.findFocusOwner(visComp) ~= nil);
            visComp = nil;
        end

        if (accessibleContext ~= nil)
            
            if (index == selected)
                
                pages.get(index).firePropertyChange(
                    AccessibleContext.ACCESSIBLE_STATE_PROPERTY,
                    AccessibleState.SELECTED, nil);

                oldName = accessibleContext.getAccessibleName();
            end

            accessibleContext.firePropertyChange(
                    AccessibleContext.ACCESSIBLE_VISIBLE_DATA_PROPERTY,
                    component, nil);
        end

        setTabComponentAt(index, nil);
        pages.remove(index);

        putClientProperty("__index_to_remove__", Integer.valueOf(index));

        
        if (selected > index)
            setSelectedIndexImpl(selected - 1, false);

        
        end else if (selected >= getTabCount())
            setSelectedIndexImpl(selected - 1, false);
            Page newSelected = (selected ~= 0)
                ? pages.get(selected - 1)
                : nil;

            changeAccessibleSelection(nil, oldName, newSelected);

        
        end else if (index == selected)
            fireStateChanged();
            changeAccessibleSelection(nil, oldName, pages.get(index));
        end

        if (component ~= nil)
            Component components[] = getComponents();
            for (int i = components.length; --i >= 0; )
                if (components[i] == component)
                    super.remove(i);
                    component.setVisible(true);
                    break;
                end
            end
        end

        if (shouldChangeFocus)
            SwingUtilities2.tabbedPaneChangeFocusTo(getSelectedComponent());
        end

        revalidate();
        repaint();
    end

    
    public void remove(Component component)
        int index = indexOfComponent(component);
        if (index ~= -1)
            removeTabAt(index);
        end else {

            Component children[] = getComponents();
            for (int i=0; i < children.length; i++)
                if (component == children[i])
                    super.remove(i);
                    break;
                end
            end
        end
    end

    
    public void remove(int index)
        removeTabAt(index);
    end

    
    public void removeAll()
        setSelectedIndexImpl(-1, true);

        int tabCount = getTabCount();

        while (tabCount-- > 0)
            removeTabAt(tabCount);
        end
    end

 ]]  
function TabbedPane:getTabCount()
	return self.pages:size()
end

 --[[   
    public int getTabRunCount()
        if (ui ~= nil)
            return ((TabbedPaneUI)ui).getTabRunCount(this);
        end
        return 0;
    end


    
    public String getTitleAt(int index)
        return pages.get(index).title;
    end

    
    public Icon getIconAt(int index)
        return pages.get(index).icon;
    end

    
    public Icon getDisabledIconAt(int index)
        Page page = pages.get(index);
        if (page.disabledIcon == nil)
            page.disabledIcon = UIManager.getLookAndFeel().getDisabledIcon(this, page.icon);
        end
        return page.disabledIcon;
    end

    
    public String getToolTipTextAt(int index)
        return pages.get(index).tip;
    end

    
    public Color getBackgroundAt(int index)
        return pages.get(index).getBackground();
    end

    
    public Color getForegroundAt(int index)
        return pages.get(index).getForeground();
    end

    
    public boolean isEnabledAt(int index)
        return pages.get(index).isEnabled();
    end
--]]
    
function TabbedPane:getComponentAt(index)
	return self.pages:get(index).component
end

--[[
    
    public int getMnemonicAt(int tabIndex)
        checkIndex(tabIndex);

        Page page = pages.get(tabIndex);
        return page.getMnemonic();
    end

    
    public int getDisplayedMnemonicIndexAt(int tabIndex)
        checkIndex(tabIndex);

        Page page = pages.get(tabIndex);
        return page.getDisplayedMnemonicIndex();
    end

    
    public Rectangle getBoundsAt(int index)
        checkIndex(index);
        if (ui ~= nil)
            return ((TabbedPaneUI)ui).getTabBounds(this, index);
        end
        return nil;
    end


    
    public void setTitleAt(int index, String title)
        Page page = pages.get(index);
        String oldTitle =page.title;
        page.title = title;

        if (oldTitle ~= title)
            firePropertyChange("indexForTitle", -1, index);
        end
        page.updateDisplayedMnemonicIndex();
        if ((oldTitle ~= title) and (accessibleContext ~= nil))
            accessibleContext.firePropertyChange(
                    AccessibleContext.ACCESSIBLE_VISIBLE_DATA_PROPERTY,
                    oldTitle, title);
        end
        if (title == nil or oldTitle == nil or
            !title.equals(oldTitle))
            revalidate();
            repaint();
        end
    end

    
    public void setIconAt(int index, Icon icon)
        Page page = pages.get(index);
        Icon oldIcon = page.icon;
        if (icon ~= oldIcon)
            page.icon = icon;

            /* If the default icon has really changed and we had
             * generated the disabled icon for this page, then
             * clear the disabledIcon field of the page.
             */
            if (page.disabledIcon instanceof UIResource)
                page.disabledIcon = nil;
            end

            if (accessibleContext ~= nil)
                accessibleContext.firePropertyChange(
                        AccessibleContext.ACCESSIBLE_VISIBLE_DATA_PROPERTY,
                        oldIcon, icon);
            end
            revalidate();
            repaint();
        end
    end

    
    public void setDisabledIconAt(int index, Icon disabledIcon)
        Icon oldIcon = pages.get(index).disabledIcon;
        pages.get(index).disabledIcon = disabledIcon;
        if (disabledIcon ~= oldIcon and !isEnabledAt(index))
            revalidate();
            repaint();
        end
    end

    
    public void setToolTipTextAt(int index, String toolTipText)
        String oldToolTipText = pages.get(index).tip;
        pages.get(index).tip = toolTipText;

        if ((oldToolTipText ~= toolTipText) and (accessibleContext ~= nil))
            accessibleContext.firePropertyChange(
                    AccessibleContext.ACCESSIBLE_VISIBLE_DATA_PROPERTY,
                    oldToolTipText, toolTipText);
        end
        if (!haveRegistered and toolTipText ~= nil)
            ToolTipManager.sharedInstance().registerComponent(this);
            haveRegistered = true;
        end
    end


    public void setBackgroundAt(int index, Color background)
        Color oldBg = pages.get(index).background;
        pages.get(index).setBackground(background);
        if (background == nil or oldBg == nil or
            !background.equals(oldBg))
            Rectangle tabBounds = getBoundsAt(index);
            if (tabBounds ~= nil)
                repaint(tabBounds);
            end
        end
    end

    
    public void setForegroundAt(int index, Color foreground)
        Color oldFg = pages.get(index).foreground;
        pages.get(index).setForeground(foreground);
        if (foreground == nil or oldFg == nil or
            !foreground.equals(oldFg))
            Rectangle tabBounds = getBoundsAt(index);
            if (tabBounds ~= nil)
                repaint(tabBounds);
            end
        end
    end

    
    public void setEnabledAt(int index, boolean enabled)
        boolean oldEnabled = pages.get(index).isEnabled();
        pages.get(index).setEnabled(enabled);
        if (enabled ~= oldEnabled)
            revalidate();
            repaint();
        end
    end

    
    public void setComponentAt(int index, Component component)
        Page page = pages.get(index);
        if (component ~= page.component)
            boolean shouldChangeFocus = false;

            if (page.component ~= nil)
                shouldChangeFocus =
                    (SwingUtilities.findFocusOwner(page.component) ~= nil);

                synchronized(getTreeLock())
                    int count = getComponentCount();
                    Component children[] = getComponents();
                    for (int i = 0; i < count; i++)
                        if (children[i] == page.component)
                            super.remove(i);
                        end
                    end
                end
            end

            page.component = component;
            boolean selectedPage = (getSelectedIndex() == index);

            if (selectedPage)
                self.visComp = component;
            end

            if (component ~= nil)
                component.setVisible(selectedPage);
                addImpl(component, nil, -1);

                if (shouldChangeFocus)
                    SwingUtilities2.tabbedPaneChangeFocusTo(component);
                end
            end else {
                repaint();
            end

            revalidate();
        end
    end

    
    public void setDisplayedMnemonicIndexAt(int tabIndex, int mnemonicIndex)
        checkIndex(tabIndex);

        Page page = pages.get(tabIndex);

        page.setDisplayedMnemonicIndex(mnemonicIndex);
    end

    
    public void setMnemonicAt(int tabIndex, int mnemonic)
        checkIndex(tabIndex);

        Page page = pages.get(tabIndex);
        page.setMnemonic(mnemonic);

        firePropertyChange("mnemonicAt", nil, nil);
    end


    
    public int indexOfTab(String title)
        for(int i = 0; i < getTabCount(); i++)
            if (getTitleAt(i).equals(title == nil? "" : title))
                return i;
            end
        end
        return -1;
    end

    
    public int indexOfTab(Icon icon)
        for(int i = 0; i < getTabCount(); i++)
            Icon tabIcon = getIconAt(i);
            if ((tabIcon ~= nil and tabIcon.equals(icon)) or
                (tabIcon == nil and tabIcon == icon))
                return i;
            end
        end
        return -1;
    end

    ]]
function TabbedPane:indexOfComponent(component)
	for i = 1, self:getTabCount() do
		local c = self:getComponentAt(i)
		if ((c ~= nil and c == component) or
			(c == nil and c == component)) then
			return i
		end
	end
	return -1
end
--[[
    
    public int indexAtLocation(int x, int y)
        if (ui ~= nil)
            return ((TabbedPaneUI)ui).tabForCoordinate(this, x, y);
        end
        return -1;
    end


    
    public String getToolTipText(MouseEvent event)
        if (ui ~= nil)
            int index = ((TabbedPaneUI)ui).tabForCoordinate(this, event.getX(), event.getY());

            if (index ~= -1)
                return pages.get(index).tip;
            end
        end
        return super.getToolTipText(event);
    end
]]

function TabbedPane:checkIndex(index)
	if (index < 0 or index >= self.pages:size()) then
		throw(IndexOutOfBoundsException("Index: " .. index .. ", Tab count: " .. self.pages:size()))
	end
end

--[[
    
    private void writeObject(ObjectOutputStream s) throws IOException {
        s.defaultWriteObject();
        if (getUIClassID().equals(uiClassID))
            byte count = JComponent.getWriteObjCounter(this);
            JComponent.setWriteObjCounter(this, --count);
            if (count == 0 and ui ~= nil)
                ui.installUI(this);
            end
        end
    end

    /* Called from the <code>JComponent</code>'s
     * <code>EnableSerializationFocusListener</code> to
     * do any Swing-specific pre-serialization configuration.
     */
    void compWriteObjectNotify()
        super.compWriteObjectNotify();

        if (getToolTipText() == nil and haveRegistered)
            ToolTipManager.sharedInstance().unregisterComponent(this);
        end
    end

    
    private void readObject(ObjectInputStream s)
        throws IOException, ClassNotFoundException
    {
        s.defaultReadObject();
        if ((ui ~= nil) and (getUIClassID().equals(uiClassID)))
            ui.installUI(this);
        end

        if (getToolTipText() == nil and haveRegistered)
            ToolTipManager.sharedInstance().registerComponent(this);
        end
    end


    
    protected String paramString()
        String tabPlacementString;
        if (tabPlacement == TOP)
            tabPlacementString = "TOP";
        end else if (tabPlacement == BOTTOM)
            tabPlacementString = "BOTTOM";
        end else if (tabPlacement == LEFT)
            tabPlacementString = "LEFT";
        end else if (tabPlacement == RIGHT)
            tabPlacementString = "RIGHT";
        end else tabPlacementString = "";
        String haveRegisteredString = (haveRegistered ?
                                       "true" : "false");

        return super.paramString() +
        ",haveRegistered=" + haveRegisteredString +
        ",tabPlacement=" + tabPlacementString;
    end


    
    public AccessibleContext getAccessibleContext()
        if (accessibleContext == nil)
            accessibleContext = new AccessibleJTabbedPane();

            int count = getTabCount();
            for (int i = 0; i < count; i++)
                pages.get(i).initAccessibleContext();
            end
        end
        return accessibleContext;
    end

    
    protected class AccessibleJTabbedPane extends AccessibleJComponent
        implements AccessibleSelection, ChangeListener {

        
        public String getAccessibleName()
            if (accessibleName ~= nil)
                return accessibleName;
            end

            String cp = (String)getClientProperty(AccessibleContext.ACCESSIBLE_NAME_PROPERTY);

            if (cp ~= nil)
                return cp;
            end

            int index = getSelectedIndex();

            if (index >= 0)
                return pages.get(index).getAccessibleName();
            end

            return super.getAccessibleName();
        end

        
        public AccessibleJTabbedPane()
            super();
            JTabbedPane.self.model.addChangeListener(this);
        end

        public void stateChanged(ChangeEvent e)
            Object o = e.getSource();
            firePropertyChange(AccessibleContext.ACCESSIBLE_SELECTION_PROPERTY,
                               nil, o);
        end

        
        public AccessibleRole getAccessibleRole()
            return AccessibleRole.PAGE_TAB_LIST;
        end

        
        public int getAccessibleChildrenCount()
            return getTabCount();
        end

        
        public Accessible getAccessibleChild(int i)
            if (i < 0 or i >= getTabCount())
                return nil;
            end
            return pages.get(i);
        end

        
        public AccessibleSelection getAccessibleSelection()
           return this;
        end

        
        public Accessible getAccessibleAt(Point p)
            int tab = ((TabbedPaneUI) ui).tabForCoordinate(JTabbedPane.this,
                                                           p.x, p.y);
            if (tab == -1)
                tab = getSelectedIndex();
            end
            return getAccessibleChild(tab);
        end

        public int getAccessibleSelectionCount()
            return 1;
        end

        public Accessible getAccessibleSelection(int i)
            int index = getSelectedIndex();
            if (index == -1)
                return nil;
            end
            return pages.get(index);
        end

        public boolean isAccessibleChildSelected(int i)
            return (i == getSelectedIndex());
        end

        public void addAccessibleSelection(int i)
           setSelectedIndex(i);
        end

        public void removeAccessibleSelection(int i)

        end

        public void clearAccessibleSelection()

        end

        public void selectAllAccessibleSelection()

        end
    end

]]
function TabbedPane:setTabComponentAt(index, component)
	if (component ~= nil and self:indexOfComponent(component) ~= -1) then
		throw(IllegalArgumentException("Component is already added to this JTabbedPane"))
	end
	local oldValue = self:getTabComponentAt(index)
	if (component ~= oldValue) then
		local tabComponentIndex = self:indexOfTabComponent(component)
		if (tabComponentIndex ~= -1) then
			self:setTabComponentAt(tabComponentIndex, nil)
		end
		self.pages:get(index).tabComponent = component;
		self:firePropertyChange("indexForTabComponent", -1, index)
	end
end

function TabbedPane:getTabComponentAt(index)
	return self.pages:get(index).tabComponent
end

function TabbedPane:indexOfTabComponent(tabComponent)
	for i = 1, self:getTabCount() do
		local c = self:getTabComponentAt(i)
		if (c == tabComponent) then
			return i;
		end
	end
	return -1;
end

---------- TabbedPane.Page -----------

local super = TabbedPane.Page.getSuperclass()

function TabbedPane.Page:init(parent, title, icon, disabledIcon, component, tip)
	super.init(self)
	self.title = title
	self.background = nil
	self.foreground= nil
	self.icon = icon
	self.disabledIcon = disabledIcon
	--self.parent = parent
	self.component = component
	self.tip = tip
	self.enabled = true
	self.needsUIUpdate = false
	self.mnemonic = -1
	self.mnemonicIndex = -1
	self.tabComponent = nil
	return self
end

function TabbedPane.Page:setMnemonic(mnemonic)
	self.mnemonic = mnemonic;
	self:updateDisplayedMnemonicIndex()
end

function TabbedPane.Page:getMnemonic()
	return self.mnemonic
end

function TabbedPane.Page:setDisplayedMnemonicIndex(mnemonicIndex)
	if (self.mnemonicIndex ~= mnemonicIndex) then
		if (mnemonicIndex ~= -1 and (title == nil or
				mnemonicIndex < 0 or
				mnemonicIndex >= title:len())) then
			throw('IllegalArgumentException("Invalid mnemonic index: " + mnemonicIndex')
		end
		self.mnemonicIndex = mnemonicIndex;
		self.parent:firePropertyChange("displayedMnemonicIndexAt", nil, nil)
	end
end

function TabbedPane.Page:getDisplayedMnemonicIndex()
	return self.mnemonicIndex;
end

function TabbedPane.Page:updateDisplayedMnemonicIndex()
	self:setDisplayedMnemonicIndex(Utilities.findDisplayedMnemonicIndex(self.title, self.mnemonic))
end

function TabbedPane.Page:getBackground()
	return self.background ~= nil and self.background or self.parent:getBackground()
end

function TabbedPane.Page:setBackground(c)
	self.background = c
end

function TabbedPane.Page:getForeground()
	return self.foreground ~= nil and self.foreground or self.parent:getForeground()
end

function TabbedPane.Page:setForeground(c)
	self.foreground = c
end

function TabbedPane.Page:getCursor()
	return self.parent:getCursor()
end

function TabbedPane.Page:setCursor(c)
	self.parent:setCursor(c)
end

function TabbedPane.Page:getFont()
	return self.parent:getFont()
end

function TabbedPane.Page:setFont(f)
	self.parent:setFont(f)
end

function TabbedPane.Page:getFontMetrics(f)
	return self.parent:getFontMetrics(f)
end

function TabbedPane.Page:isEnabled()
	return self.enabled
end

function TabbedPane.Page:setEnabled(b)
	self.enabled = b
end

function TabbedPane.Page:isVisible()
	return self.parent:isVisible()
end

function TabbedPane.Page:setVisible(b)
	self.parent:setVisible(b)
end

function TabbedPane.Page:isShowing()
	return self.parent:isShowing()
end

function TabbedPane.Page:contains(p)
	local r = self:getBounds()
	return r:contains(p)
end

function TabbedPane.Page:getLocationOnScreen()
	 local parentLocation = self.parent:getLocationOnScreen();
	 local componentLocation = self:getLocation()
	 self.componentLocation:translate(parentLocation.x, parentLocation.y);
	 return componentLocation;
end

function TabbedPane.Page:getLocation()
	 local r = self:getBounds()
	 return Point(r.x, r.y)
end

function TabbedPane.Page:setLocation(p) 
end

function TabbedPane.Page:getBounds()
	return self.parent:getUI():getTabBounds(parent, parent:indexOfTab(self.title))
end

function TabbedPane.Page:setBounds(r)  
end

function TabbedPane.Page:getSize()
	local r = self:getBounds();
	return Dimension(r.width, r.height)
end

function TabbedPane.Page:setSize(d)
end

function TabbedPane.Page:isFocusTraversable()
	return false
end

function TabbedPane.Page:requestFocus() 
end

function TabbedPane.Page:addFocusListener(l)
end

function TabbedPane.Page:removeFocusListener(l)
end

---------- TabbedPane.Button -----------

local super = TabbedPane.Button.getSuperclass()

function TabbedPane.Button:init(label)
	super.init(self, label)
	self:addActionListener(self)
	return self
end

function TabbedPane.Button:paintComponent(g)
	if(self.selected) then
		local x, y = self:getLocationOnScreen()
		local w = self:getWidth()
		local h = self:getHeight()	
		g:drawSetColor(tocolor(50,142,254))
		g:drawFilledRect(x, y - h/5, w, h/5)
	end
	super.paintComponent(self,g)
end

function TabbedPane.Button:setSelected(selected)
	self.selected = selected
end

function TabbedPane.Button:isSelected()
	return self.selected
end

function TabbedPane.Button:isFocusOwner()
	return self:isSelected()
end

addEventHandler("onClientResourceStart", resourceRoot, function(resource) 

	local tab = TabbedPane()
	
	tab:setBounds(200,200,400,300)
	
	tab:setVisible(true)

	tab:add("Teste1", Button("Teste1"))
	--tab:add("Teste2", Button("Teste2"))
	--tab:add("Teste3", Button("Teste3"))
	--tab:add("Teste4", Button("Teste4"))
		--[[
	showCursor(true)
	
	Toolkit.getInstance():add(tab)
	]]
end)