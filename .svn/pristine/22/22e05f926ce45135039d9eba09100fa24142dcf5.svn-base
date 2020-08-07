#
#   FMS STAR/SID database class
#
#
#   Copyright (C) 2009 Scott Hamilton
#
#   You should have received a copy of the GNU General Public License
#   along with this program.  If not, see <http://www.gnu.org/licenses/>.
#

var fmsWP = {
    new : func {
        var me = {parents:[fmsWP]};

        me.wp_name = "";          # fix, navaid or pseudo waypoint name
        me.wp_parent_name = "";   # if a SID/STAR WP then the SID/STAR name, or AIRWAY name
        me.wp_type = "FIX";   # FIX, NAVAID, Termination Point, transition wp, Final Fix, Appr Fix, RWY transition, SID/STAR WP
        me.fly_type = "FlyOver";  # flyOver, flyBy, Hold, 
        me.action  = "DIRECT";  # direct, trk, intercept, vectors (not used)
        me.wp_lat  = 0.0;       # latitude
        me.wp_lon  = 0.0;       # longitude
        me.alt_cstr = 0;        # alt constraint from db or calculated altitude in ft
        me.alt_cstr_ind = 0;    # if the alt is a programmed constraint or just calculated (as part of STAR)
        me.spd_cstr = 0;        # spd constraint in kts, mach or zero
        me.spd_cstr_ind = 0;    # 0 - calculated speed, 1 - constraint
        me.hdg_radial = 0.0;    # either heading/track or radial
        me.leg_distance = 0;    # NM for this leg
        me.leg_bearing  = 0.0;  # deg bearing for this leg

        return me;
    },

}