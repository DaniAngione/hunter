App.StonehearthStartMenuView.reopen({
   init: function() {
      var self = this;

      self.menuActions.box_hunt = function(){
         self.boxHunt();
      };
		
		self._super();

      App.waitForStartMenuLoad().then(() => {
         // this is a call to a global function stored in task_manager.js
         _updateProcessingMeterShown();
      });
   },

   boxHunt: function() {
      var self = this;

      var tip = App.stonehearthClient.showTip('hunter:ui.game.menu.harvest_menu.items.box_hunt.tip_title',
            'hunter:ui.game.menu.harvest_menu.items.box_hunt.tip_description', {i18n : true});

      return App.stonehearthClient._callTool('boxHunt', function() {
         return radiant.call('hunter:box_hunt')
            .done(function(response) {
               radiant.call('radiant:play_sound', {'track' : 'stonehearth:sounds:ui:start_menu:popup'} );
               self.boxHunt();
            })
            .fail(function(response) {
               App.stonehearthClient.hideTip(tip);
            });
      });
   }
});