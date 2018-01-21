/*
 * This file is part of Haguichi, a graphical frontend for Hamachi.
 * Copyright (C) 2007-2018 Stephen Brandt <stephen@stephenbrandt.com>
 *
 * Haguichi is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published
 * by the Free Software Foundation, either version 3 of the License,
 * or (at your option) any later version.
 */

using Gtk;
using Widgets;

namespace Dialogs
{
    public class Preferences : Dialog
    {
        public  CommandsEditor commands_editor;
        
        public  CheckButton connect_on_startup;
        public  CheckButton reconnect_on_connection_loss;
        public  CheckButton disconnect_on_quit;
        public  CheckButton update_network_list;
        
        public  CheckButton notify_on_connection_loss;
        public  CheckButton notify_on_member_join;
        public  CheckButton notify_on_member_leave;
        public  CheckButton notify_on_member_online;
        public  CheckButton notify_on_member_offline;
        
        private Box ip_box;
        private GroupBox hamachi_box;
        
        private Box interval_box;
        
        public  ComboBoxText ip_combo;
        public  SpinButton interval_spin;
        
        private Label interval_label;
        
        public Preferences ()
        {
            Object (title: Text.preferences_title,
                    transient_for: Haguichi.window,
#if FOR_ELEMENTARY
                    deletable: false,
#endif
                    modal: false,
                    resizable: false,
                    use_header_bar: (int) Haguichi.dialog_use_header_bar);
            
#if FOR_ELEMENTARY
            add_button (Text.close_label, ResponseType.CLOSE).margin = 6;
            
            response.connect ((response_id) =>
            {
                if (response_id == ResponseType.CLOSE)
                {
                    hide();
                }
            });
#endif
            
            delete_event.connect (on_delete);
            
            
            notify_on_connection_loss = new CheckButton.with_mnemonic (Text.checkbox_notify_connection_lost);
            notify_on_connection_loss.active = (bool) Settings.notify_on_connection_loss.val;
            notify_on_connection_loss.toggled.connect (() =>
            {
                Settings.notify_on_connection_loss.val = notify_on_connection_loss.active;
            });
            
            notify_on_member_join = new CheckButton.with_mnemonic (Text.checkbox_notify_member_join);
            notify_on_member_join.active = (bool) Settings.notify_on_member_join.val;
            notify_on_member_join.toggled.connect (() =>
            {
                Settings.notify_on_member_join.val = notify_on_member_join.active;
            });
            
            notify_on_member_leave = new CheckButton.with_mnemonic (Text.checkbox_notify_member_leave);
            notify_on_member_leave.active = (bool) Settings.notify_on_member_leave.val;
            notify_on_member_leave.toggled.connect (() =>
            {
                Settings.notify_on_member_leave.val = notify_on_member_leave.active;
            });
            
            notify_on_member_online = new CheckButton.with_mnemonic (Text.checkbox_notify_member_online);
            notify_on_member_online.active = (bool) Settings.notify_on_member_online.val;
            notify_on_member_online.toggled.connect (() =>
            {
                Settings.notify_on_member_online.val = notify_on_member_online.active;
            });
            
            notify_on_member_offline = new CheckButton.with_mnemonic (Text.checkbox_notify_member_offline);
            notify_on_member_offline.active = (bool) Settings.notify_on_member_offline.val;
            notify_on_member_offline.toggled.connect (() =>
            {
                Settings.notify_on_member_offline.val = notify_on_member_offline.active;
            });
            
            GroupBox tray_box = new GroupBox (Text.notify_group);
            tray_box.add_widget (notify_on_connection_loss);
            tray_box.add_widget (notify_on_member_join);
            tray_box.add_widget (notify_on_member_leave);
            tray_box.add_widget (notify_on_member_online);
            tray_box.add_widget (notify_on_member_offline);
            
            Box desktop_box = new Box (Orientation.VERTICAL, 0);
            desktop_box.pack_start (tray_box, false, false, 0);
            desktop_box.pack_start (new Box (Orientation.VERTICAL, 0), true, true, 8);
            
            
            commands_editor = new CommandsEditor();
            
            
            ip_combo = new ComboBoxText();
            ip_combo.append_text (Text.protocol_both);
            ip_combo.append_text (Text.protocol_ipv4);
            ip_combo.append_text (Text.protocol_ipv6);
            ip_combo.active = (int) Utils.protocol_to_int ((string) Settings.protocol.val);
            ip_combo.changed.connect (() =>
            {
                Settings.protocol.val = Utils.protocol_to_string (ip_combo.active);
            });
            
            Label ip_label = new Label.with_mnemonic (Text.protocol_label + "  ");
            ip_label.mnemonic_widget = ip_combo;
            
            ip_box = new Box (Orientation.HORIZONTAL, 0);
            ip_box.pack_start (ip_label, false, false, 0);
            ip_box.pack_start (ip_combo, false, false, 0);
            
            hamachi_box = new GroupBox ("Hamachi");
            hamachi_box.add_widget (ip_box);
            
            connect_on_startup = new CheckButton.with_mnemonic (Text.connect_on_startup);
            connect_on_startup.active = (bool) Settings.connect_on_startup.val;
            connect_on_startup.toggled.connect (() =>
            {
                Settings.connect_on_startup.val = connect_on_startup.active;       
            });
            
            reconnect_on_connection_loss = new CheckButton.with_mnemonic (Text.reconnect_on_connection_loss);
            reconnect_on_connection_loss.active = (bool) Settings.reconnect_on_connection_loss.val;
            reconnect_on_connection_loss.toggled.connect (() =>
            {
                Settings.reconnect_on_connection_loss.val = reconnect_on_connection_loss.active;       
            });
            
            disconnect_on_quit = new CheckButton.with_mnemonic (Text.disconnect_on_quit);
            disconnect_on_quit.active = (bool) Settings.disconnect_on_quit.val;
            disconnect_on_quit.toggled.connect (() =>
            {
                Settings.disconnect_on_quit.val = disconnect_on_quit.active;
            });
            
            update_network_list = new CheckButton();
            update_network_list.use_underline = true;
            update_network_list.active = (bool) Settings.update_network_list.val;
            update_network_list.toggled.connect (() =>
            {
                Settings.update_network_list.val = update_network_list.active;
                interval_spin.sensitive = update_network_list.active;
            });
            
            interval_spin = new SpinButton.with_range (0, 999, 1);
            interval_spin.sensitive = (bool) Settings.update_network_list.val;
            interval_spin.value = (int) Settings.update_interval.val;
            interval_spin.value_changed.connect (() =>
            {
                Settings.update_interval.val = (int) interval_spin.value;
            });
            interval_spin.max_length = 3;
            
            interval_label = new Label (null);
            interval_label.use_underline = true;
            interval_label.mnemonic_widget = interval_spin;
            interval_label.halign = Align.START;
            
            interval_box = new Box (Orientation.HORIZONTAL, 0);
            interval_box.pack_start (update_network_list, false, false, 0);
            interval_box.pack_start (interval_spin,       false, false, 0);
            interval_box.pack_start (interval_label,      false, false, 0);
            
            GroupBox behavior_box = new GroupBox (Text.behavior_group);
            behavior_box.add_widget (connect_on_startup);
            behavior_box.add_widget (reconnect_on_connection_loss);
            behavior_box.add_widget (disconnect_on_quit);
            behavior_box.add_widget (interval_box);
            
            Box system_box = new Box (Orientation.VERTICAL, 0);
            system_box.pack_start (hamachi_box,  false, false, 0);
            system_box.pack_start (behavior_box, false, false, 0);
            system_box.pack_start (new Box (Orientation.VERTICAL, 0), true, true, 8);
            
            
            Stack container = new Stack();
            container.expand = true;
            container.add_titled (system_box,      "system",   Text.general_tab);
            container.add_titled (commands_editor, "commands", Text.commands_tab);
            container.add_titled (desktop_box,     "desktop",  Text.desktop_tab);
            
            StackSwitcher switcher = new StackSwitcher();
            switcher.stack  = container;
            switcher.expand = true;
            switcher.halign = Gtk.Align.CENTER;
            
            Box content_area = get_content_area() as Box;
            
            if (Haguichi.dialog_use_header_bar)
            {
                var titlebar = new HeaderBar();
                titlebar.custom_title = switcher;
                titlebar.show_close_button = true;
                titlebar.show_all();
                
                set_titlebar (titlebar);
                
                container.transition_type = StackTransitionType.SLIDE_LEFT_RIGHT;
            }
            else
            {
                content_area.add (switcher);
#if !FOR_ELEMENTARY
                switcher.margin_top = 12;
#endif
            }
            
            content_area.add (container);
            content_area.show_all();
            
            set_interval_string();
        }
        
        public void set_interval_string ()
        {
            string[] interval_string = Text.update_network_list_interval ((int) interval_spin.value).split ("%S", 2);
            
            update_network_list.label = interval_string[0] + " ";
            interval_label.label      = " " + interval_string[1];
        }
        
        public void open ()
        {
            show();
            present();
        }
        
        private bool on_delete ()
        {
            hide();
            return true;
        }
    }
}
