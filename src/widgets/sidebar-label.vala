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

public class SidebarLabel : Label
{
    public SidebarLabel (string _label)
    {
        label = Utils.remove_colons (_label);
        xalign = 1.0f;
        margin_top = 6;
        margin_bottom = 6;
        width_chars = 10;
        ellipsize = Pango.EllipsizeMode.START;
        get_style_context().add_class ("dim-label");
    }
}
