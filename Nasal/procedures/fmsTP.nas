#
#   FMS Terminal Procedure class
#
#
#   Copyright (C) 2009 Scott Hamilton
#
#   You should have received a copy of the GNU General Public License
#   along with this program.  If not, see <http://www.gnu.org/licenses/>.
#

var fmsTP = {
    new : func{
        var me = {parents:[fmsTP]};

        me.wp_name = "";
        me.tp_type = "";   # SID, STAR, IAP
        me.runways = [];   # array of runway names of this procedure
        me.wpts    = [];   # array of fmsWP
        me.rwy_tw  = [];   # array of runway transition waypoints if SID or approach transition for STAR
        me.transitions = [];  # array of transition paths


        return me;
    },

}