
-- Meter System Policies
DROP POLICY IF EXISTS "Admin full access to tariffs" ON tariffs;
CREATE POLICY "Admin full access to tariffs" ON tariffs FOR ALL USING (has_role('admin'));
DROP POLICY IF EXISTS "Admin full access to gateways" ON gateways;
CREATE POLICY "Admin full access to gateways" ON gateways FOR ALL USING (has_role('admin'));
DROP POLICY IF EXISTS "Admin full access to customers" ON customers;
CREATE POLICY "Admin full access to customers" ON customers FOR ALL USING (has_role('admin'));
DROP POLICY IF EXISTS "Admin full access to meters" ON meters;
CREATE POLICY "Admin full access to meters" ON meters FOR ALL USING (has_role('admin'));

DROP POLICY IF EXISTS "Staff read tariffs" ON tariffs;
CREATE POLICY "Staff read tariffs" ON tariffs FOR SELECT USING (has_role('staff'));
DROP POLICY IF EXISTS "Staff read gateways" ON gateways;
CREATE POLICY "Staff read gateways" ON gateways FOR SELECT USING (has_role('staff'));
DROP POLICY IF EXISTS "Staff read customers" ON customers;
CREATE POLICY "Staff read customers" ON customers FOR SELECT USING (has_role('staff'));
DROP POLICY IF EXISTS "Staff read meters" ON meters;
CREATE POLICY "Staff read meters" ON meters FOR SELECT USING (has_role('staff'));

DROP POLICY IF EXISTS "Staff create token sales" ON token_sales;
CREATE POLICY "Staff create token sales" ON token_sales FOR INSERT WITH CHECK (has_role('staff'));
DROP POLICY IF EXISTS "Staff read token sales" ON token_sales;
CREATE POLICY "Staff read token sales" ON token_sales FOR SELECT USING (has_role('staff'));
DROP POLICY IF EXISTS "Staff create token records" ON token_records;
CREATE POLICY "Staff create token records" ON token_records FOR INSERT WITH CHECK (has_role('staff'));
DROP POLICY IF EXISTS "Staff read token records" ON token_records;
CREATE POLICY "Staff read token records" ON token_records FOR SELECT USING (has_role('staff'));

DROP POLICY IF EXISTS "Visitor read tariffs" ON tariffs;
CREATE POLICY "Visitor read tariffs" ON tariffs FOR SELECT USING (has_role('visitor'));
DROP POLICY IF EXISTS "Visitor read customers" ON customers;
CREATE POLICY "Visitor read customers" ON customers FOR SELECT USING (has_role('visitor'));
DROP POLICY IF EXISTS "Visitor read meters" ON meters;
CREATE POLICY "Visitor read meters" ON meters FOR SELECT USING (has_role('visitor'));
DROP POLICY IF EXISTS "Visitor read token sales" ON token_sales;
CREATE POLICY "Visitor read token sales" ON token_sales FOR SELECT USING (has_role('visitor'));

-- CRM Policies
DROP POLICY IF EXISTS "Users can view active pipelines" ON crm_pipelines;
CREATE POLICY "Users can view active pipelines" ON crm_pipelines FOR SELECT USING (is_active = true);
DROP POLICY IF EXISTS "Authenticated users can create pipelines" ON crm_pipelines;
CREATE POLICY "Authenticated users can create pipelines" ON crm_pipelines FOR INSERT WITH CHECK (true);
DROP POLICY IF EXISTS "Users can view all contacts" ON crm_contacts;
CREATE POLICY "Users can view all contacts" ON crm_contacts FOR SELECT USING (true);
DROP POLICY IF EXISTS "Authenticated users can create contacts" ON crm_contacts;
CREATE POLICY "Authenticated users can create contacts" ON crm_contacts FOR INSERT WITH CHECK (true);
DROP POLICY IF EXISTS "Users can update contacts" ON crm_contacts;
CREATE POLICY "Users can update contacts" ON crm_contacts FOR UPDATE USING (true);
DROP POLICY IF EXISTS "Users can delete contacts" ON crm_contacts;
CREATE POLICY "Users can delete contacts" ON crm_contacts FOR DELETE USING (true);
DROP POLICY IF EXISTS "Users can view all opportunities" ON crm_opportunities;
CREATE POLICY "Users can view all opportunities" ON crm_opportunities FOR SELECT USING (true);
DROP POLICY IF EXISTS "Authenticated users can create opportunities" ON crm_opportunities;
CREATE POLICY "Authenticated users can create opportunities" ON crm_opportunities FOR INSERT WITH CHECK (true);
DROP POLICY IF EXISTS "Users can update opportunities" ON crm_opportunities;
CREATE POLICY "Users can update opportunities" ON crm_opportunities FOR UPDATE USING (true);
DROP POLICY IF EXISTS "Users can delete opportunities" ON crm_opportunities;
CREATE POLICY "Users can delete opportunities" ON crm_opportunities FOR DELETE USING (true);
DROP POLICY IF EXISTS "Users can view all activities" ON crm_activities;
CREATE POLICY "Users can view all activities" ON crm_activities FOR SELECT USING (true);
DROP POLICY IF EXISTS "Authenticated users can create activities" ON crm_activities;
CREATE POLICY "Authenticated users can create activities" ON crm_activities FOR INSERT WITH CHECK (true);
DROP POLICY IF EXISTS "Users can update activities" ON crm_activities;
CREATE POLICY "Users can update activities" ON crm_activities FOR UPDATE USING (true);
DROP POLICY IF EXISTS "Users can delete activities" ON crm_activities;
CREATE POLICY "Users can delete activities" ON crm_activities FOR DELETE USING (true);
DROP POLICY IF EXISTS "Everyone can view tags" ON crm_tags;
CREATE POLICY "Everyone can view tags" ON crm_tags FOR SELECT USING (true);
DROP POLICY IF EXISTS "Authenticated users can create tags" ON crm_tags;
CREATE POLICY "Authenticated users can create tags" ON crm_tags FOR INSERT WITH CHECK (true);

-- Notification Policies
DROP POLICY IF EXISTS "Users can view own notifications" ON notifications;
CREATE POLICY "Users can view own notifications" ON notifications FOR SELECT USING (auth.uid() = user_id);
DROP POLICY IF EXISTS "Users can update own notifications" ON notifications;
CREATE POLICY "Users can update own notifications" ON notifications FOR UPDATE USING (auth.uid() = user_id);
DROP POLICY IF EXISTS "System can create notifications" ON notifications;
CREATE POLICY "System can create notifications" ON notifications FOR INSERT WITH CHECK (true);
;
