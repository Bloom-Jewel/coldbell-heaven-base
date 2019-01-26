class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  
  after_action do
    response.body.gsub!(/>\s+</,'><')
  end
  
  private
  def _safe_error
    yield
  rescue => e
    render html: "<h1>%s</h1><h2>%s</h2><ul>%s</ul>".html_safe % [
      'Internal Server Error',
      [e.class,e.message].map(&:to_s).reject(&:empty?).join(':'),
      e.backtrace.map { |bt| "<li>#{bt}</li>".html_safe }.join('').html_safe
    ],status: 500
  end
  
  def _fetch_skills(skill_ids, skills: nil, link: true)
    skill_ids = skill_ids.to_a
    skills = skills.is_a?(Array) ? skills : []
    SQLite3::Database.open('db/shiny.mdb') do |db|
      if skill_ids.empty? then
        sk_qs = '1'
      else
        sk_qs = 'id in (%s)' % ((['?'] * skill_ids.size)*',')
      end
      db.query('select * from skill_data where %s' % sk_qs,skill_ids) do |r|
        r.each_hash do |c|
          skills << c
        end
      end
      db.query('select * from memory_appeals where %s' % sk_qs,skill_ids) do |r|
        r.each_hash do |c|
          skills << c
        end
      end
      
      ls_id = skills.map do |s| String(s['id']).tap { |x| x[1]='9' } end
      ls_qs = 'id in (%s)' % [ls_id.map do '?' end.join(',')]
      db.query('select * from link_skill where %s' % ls_qs,ls_id) do |r|
        r.each_hash do |c|
          s = skills.find do |x|
            ski = Integer(String(x['id']).tap { |_x| _x[1]='9' })
            ski == c['id']
          end
          next if s.nil?
          s['link_skill'] = c
          skills << c
        end
      end
      
      sid = skills.map do |s| String(s['id']) end
      sqs = 'skill_id in (%s)' % [sid.map do '?' end.join(',')]
      db.query('select * from skill_effects where %s' % sqs,sid) do |r|
        r.each_hash do |c|
          s = skills.find do |s| s['id'] == c['skill_id'] end
          next if s.nil?
          s['effects'] ||= []
          s['effects'] << c
        end
      end
      
      unless link
        skills.reject! do |s| String(s['id'])[1] == '9' end
      end
    end
    skills
  end
  
  def _fetch_card_skills(idol)
    skills = {
      panels: [],
      memory: []
    }
    SQLite3::Database.open('db/shiny.mdb') do |db|
      list = skills[:panels]
      
      db.query('select * from skill_panels where idol_id = ?',[idol]) do |r|
        r.each_hash do |c|
          list << c
        end
      end
      next if list.empty?
      
      (memlist,) = db.get_first_row('select idol_memory_appeal_group_id from idol_data where id = ?', idol)
      mgrp = []
      memlist&.tap do
        mgrp = db.execute('select id from memory_appeals where idol_memory_appeal_group_id = ?',memlist).flatten
      end
      
      list_id = list.map do |s| s['skill_id'] end
      list_lk = list_id.select{|x|x.size <= 9}
      
      list_id += list_lk.map do |agid| db.execute('select id from active_skills where id like ?', ["%d%%" % agid]) end.flatten
      list_qs = 'id in (%s)' % [list_id.map do '?' end.join(',')]
      
      sgroup = {}
      sks = _fetch_skills(list_id)
      _fetch_skills(mgrp, skills: skills[:memory], link: false) if memlist
      
      alr = []
      [
        [:active, 'active_skills'],
        [:passive, 'passive_skills'],
        [:misc, 'skill_data']
      ].each do |(k, t)|
        li = db.execute('select id from %s where %s' % [t, list_qs],list_id).flatten
        li -= alr
        sgroup[k] = li
        alr |= li
      end
      
      list.each do |skpane|
        sid  = skpane['skill_id']
        sid_ = String(sid)
        sgm  = sgroup.find do |k,vl| vl.any? do |vid| String(vid).start_with?(sid_) end end.first
        sgr  = "%s_skills" % sgm
        skpane[sgr] ||= []
        skpane[sgr] <<  sks.find do |s| String(s['id']).start_with?(sid_) end
      end
    end if idol.is_a?(Integer)
    skills
  end
end
