/*
 * This file is part of Haguichi, a graphical frontend for Hamachi.
 * Copyright (C) 2007-2016 Stephen Brandt <stephen@stephenbrandt.com>
 *
 * Haguichi is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published
 * by the Free Software Foundation, either version 3 of the License,
 * or (at your option) any later version.
 */

public class Command : Object
{
    public static string sudo;
    public static string sudo_args;
    public static string sudo_start;
    
    public static string terminal;
    public static string file_manager;
    public static string remote_desktop;
    
    public static void init ()
    {
        determine_sudo();
        determine_terminal();
        determine_file_manager();
        determine_remote_desktop();
    }
    
    public static void execute (string command)
    {
        if (command == "")
        {
            return;
        }
        
        try
        {
            GLib.Process.spawn_command_line_async (command);
        }
        catch (SpawnError e)
        {
            Debug.log (Debug.domain.ERROR, "Command.execute", e.message);
        }
    }
    
    public static string return_output (string command)
    {
        string output = "error";
        
        try
        {
            GLib.Process.spawn_command_line_sync (command, out output);
        }
        catch (SpawnError e)
        {
            Debug.log (Debug.domain.ERROR, "Command.return_output", e.message);
        }
        
        if (output.contains (".. failed, busy")) // Keep trying until it's not busy anymore
        {
            Debug.log (Debug.domain.HAMACHI, "Command.return_output", "Hamachi is busy, waiting to try again...");
            Thread.usleep (100000);
            
            output = return_output (command);
        }
        
        return output;
    }
    
    public static bool exists (string? command)
    {
        if (command == null)
        {
            return false;
        }
        
        string output = return_output ("bash -c \"command -v " + command + " &>/dev/null || echo 'command not found'\"");
        
        if (output.contains ("command not found"))
        {
            return false;
        }
        else
        {
            return true;
        }
    }
    
    public static bool custom_exists (string command_ipv4, string command_ipv6)
    {
        if ((exists (replace_variables (command_ipv4, "", "", "").split (" ", 0)[0])) ||
            (exists (replace_variables (command_ipv6, "", "", "").split (" ", 0)[0])))
        {
            return true;
        }
        else
        {
            return false;
        }
    }
    
    public static void determine_sudo ()
    {
        new Thread<void*> (null, determine_sudo_thread);
    }
    
    private static void* determine_sudo_thread ()
    {
        sudo       = "";
        sudo_args  = "";
        sudo_start = "-- ";
        
        string   command  = (string) Settings.command_for_super_user.val;
        string[] commands = {"pkexec", "gksudo", "gksu", "gnomesu", "kdesudo", "kdesu", "sudo"};
        
        if ((command in commands) &&
            (exists (command)))
        {
            sudo = command;
        }
        else
        {
            foreach (string c in commands)
            {
                if ((sudo == "") &&
                    (exists (c)))
                {
                    sudo = c;
                }
            }
        }
        
        if (sudo == "pkexec")
        {
            sudo_start = "";
        }
        else if (sudo.has_prefix ("gksu"))
        {
            sudo_args = "--sudo-mode -D \"" + Text.app_name + "\" ";
        }
        
        Debug.log (Debug.domain.ENVIRONMENT, "Command.determine_sudo_thread", "Command for sudo: " + sudo);
        return null;
    }
    
    public static void determine_terminal ()
    {
        new Thread<void*> (null, determine_terminal_thread);
    }
    
    private static void* determine_terminal_thread ()
    {
        terminal = "gnome-terminal";
        
        if (exists ("gnome-terminal"))
        {
            // Keep
        }
        else if (exists ("mate-terminal"))
        {
            terminal = "mate-terminal";
        }
        else if (exists ("pantheon-terminal"))
        {
            terminal = "pantheon-terminal";
        }
        else if (exists ("xfce4-terminal"))
        {
            terminal = "xfce4-terminal";
        }
        else if (exists ("konsole"))
        {
            terminal = "konsole";
        }
        else if (exists ("lxterminal"))
        {
            terminal = "lxterminal";
        }
        else if (exists ("xterm"))
        {
            terminal = "xterm";
        }
        
        Debug.log (Debug.domain.ENVIRONMENT, "Command.determine_terminal_thread", "Command for terminal: " + terminal);
        return null;
    }
    
    public static void determine_file_manager ()
    {
        new Thread<void*> (null, determine_file_manager_thread);
    }
    
    private static void* determine_file_manager_thread ()
    {
        file_manager = "nautilus";
        
        if (exists ("nautilus"))
        {
            // Keep
        }
        else if (exists ("caja"))
        {
            file_manager = "caja";
        }
        else if (exists ("nemo"))
        {
            file_manager = "nemo";
        }
        else if (exists ("pantheon-files"))
        {
            file_manager = "pantheon-files";
        }
        else if (exists ("thunar"))
        {
            file_manager = "thunar";
        }
        else if (exists ("dolphin"))
        {
            file_manager = "dolphin";
        }
        else if (exists ("pcmanfm"))
        {
            file_manager = "pcmanfm";
        }
        
        Debug.log (Debug.domain.ENVIRONMENT, "Command.determine_file_manager_thread", "Command for file manager: " + file_manager);
        return null;
    }
    
    public static void determine_remote_desktop ()
    {
        new Thread<void*> (null, determine_remote_desktop_thread);
    }
    
    private static void* determine_remote_desktop_thread ()
    {
        remote_desktop = "vinagre";
        
        if (exists ("vinagre"))
        {
            // Keep
        }
        else if (exists ("krdc"))
        {
            remote_desktop = "krdc";
        }
        
        Debug.log (Debug.domain.ENVIRONMENT, "Command.determine_remote_desktop_thread", "Command for remote desktop: " + remote_desktop);
        return null;
    }
    
    public static string return_custom (Member? member, string command_ipv4, string command_ipv6, string priority)
    {
        string command = "";
        string address = "";
        
        if (Hamachi.ip_version == "Both")
        {
            if (priority == "IPv4")
            {
                if (member.ipv4 != null)
                {
                    command = command_ipv4;
                    address = member.ipv4;
                }
                else
                {
                    command = command_ipv6;
                    address = member.ipv6;
                }
            }
            if (priority == "IPv6")
            {
                if (member.ipv6 != null)
                {
                    command = command_ipv6;
                    address = member.ipv6;
                }
                else
                {
                    command = command_ipv4;
                    address = member.ipv4;
                }
            }
        }
        else if (Hamachi.ip_version == "IPv4")
        {
            command = command_ipv4;
            address = member.ipv4;
        }
        else if (Hamachi.ip_version == "IPv6")
        {
            command = command_ipv6;
            address = member.ipv6;
        }
        
        return replace_variables (command, address, member.nick, member.client_id);
    }
    
    public static string replace_variables (owned string command, string address, string nick, string id)
    {
        try
        {
            command = command.replace ("%A",  address);
            command = command.replace ("%N",  nick   );
            command = command.replace ("%ID", id     );
            
            string quote = (terminal == "konsole") ? "" : "\"";
            
            command = new Regex ("%TERMINAL (.*)").replace (command, -1, 0, terminal + " -e " + quote + "\\1" + quote);
            command = command.replace ("%FILEMANAGER", file_manager);
            command = command.replace ("%REMOTEDESKTOP", remote_desktop);
            command = command.replace ("{COLON}", ";");
        }
        catch (RegexError e)
        {
            Debug.log (Debug.domain.ERROR, "Command.replace_variables", e.message);
        }
        
        return command;
    }
    
    public static string[] return_default ()
    {
        string[] command  = new string[] {""};
        string[] commands = (string[]) Settings.custom_commands.val;
        
        foreach (string _string in commands)
        {
            string[] _array = _string.split (";", 6);
            
            if ((_array.length == 6) &&
                (_array[1] == "true"))
            {
                command = _array;
            }
        }
        
        return command;
    }
    
    public static void open_uri (string uri)
    {
        try
        {
            Gtk.show_uri (null, uri, Gdk.CURRENT_TIME);
        }
        catch (Error e)
        {
            Debug.log (Debug.domain.ERROR, "Command.open_uri", e.message);
        }
    }
}
