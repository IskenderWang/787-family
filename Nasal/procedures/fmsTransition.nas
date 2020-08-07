#
#   FMS STAR/SID transition data class
#
#
#   Copyright (C) 2009 Scott Hamilton
#
#   You should have received a copy of the GNU General Public License
#   along with this program.  If not, see <http://www.gnu.org/licenses/>.
#

var fmsTransition = {
    new : func{
        var me = {parents:[fmsTransition]};

        me.trans_name = "";
        me.trans_type = "SID";   # sid transition, star transition, rwy transition, approach transition
        me.trans_wpts = [];      # array of fmsWP types

        return me;
    },

}