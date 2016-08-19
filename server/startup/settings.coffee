# Remove runtime settings (non-persistent)
Meteor.startup ->
	RocketChat.models.Settings.update({ ts: { $lt: RocketChat.settings.ts } }, { $set: { hidden: true } })
	#change this when deploy to point the android/ ios Apps to the server or set ROOT_URL
	# 192.168.1.5:3000 for maabed
	process.env.ROOT_URL = 'http://elb-stitch-2601.aptible.in'
	process.env.MOBILE_ROOT_URL = 'http://elb-stitch-2601.aptible.in'
	process.env.MOBILE_DDP_URL = 'http://elb-stitch-2601.aptible.in'