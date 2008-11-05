require 'rexml/document'

module WidgetHelper
  include REXML
  
  @@motorsvg = nil
  
  def svg_read_inkscape_page(motors) 
    doc = REXML::Document.new File.new("app/views/#{controller.controller_name}/#{controller.action_name}.svg") 
    svg_remove_unnecessary_inkscape doc
    
    groups_with_labels = {};
    doc.each_element '//g[@inkscape:label]' do |g| 
      groups_with_labels[g.attributes['inkscape:label']] ||= []
      groups_with_labels[g.attributes['inkscape:label']] << g
    end
    
    defs = REXML::XPath.first doc, "//defs"
    svg_insert_motor_defs(defs)
    
    motors.each do |m|
      if groups_with_labels.has_key? m.tagname
        groups_with_labels[m.tagname].each do |g|
          svg_insert_motor(m, g)
          g.attributes['id'] = m.tagname
        end
      end
    end
    svg_add_clickable_filter defs
    doc
  end
  
  def svg_remove_unnecessary_inkscape doc
    doc.elements.delete_all "//style"
    doc.elements.delete_all "//inkscape:perspective"
    doc.elements.delete_all "//sodipodi:namedview"
    doc.elements.delete_all "//metadata"
    doc.elements.delete_all "//defs/*"
  end
  
  def svg_add_clickable_filter defs
    clickableFilter = REXML::Document.new <<-END
              <defs>
                <filter id="ClickableFilter" >
                  <feColorMatrix type="matrix" in="SourceGraphic" values="0.5 0 0 0 0.5   0 0.5 1 0 0.5   0 0 0.5 0 0.5    0 0 0 1 0" />
                </filter>
                <filter id="BlinkFilter" >
                  <feColorMatrix type="matrix" in="SourceGraphic" id="blinkfiltermatrix" values="1 0 0 0 0   0 1 0 0  0 0 1 0 0    0 0 0 1 0" />
                </filter>
              </defs>
              END
    clickableFilter.root.each_element do |el|
      defs.add_element el.deep_clone
    end
  end
  
  def svg_read_motor (motor)
    f = File.new('app/views/svgtest/_motor.svg')
    if not @@motorsvg or f.mtime != @@motorsvg['mtime'] or true
      @@motorsvg = {}
      @@motorsvg['doc'] = Document.new f
      @@motorsvg['mtime'] = f.mtime
      @@motorsvg['g'] = REXML::XPath.first @@motorsvg['doc'], '//g'
    end
		g = @@motorsvg['g'].deep_clone
      
    el = REXML::XPath.first g, '//[@inkscape:label="error"]'
    if motor.value[0] != 0
      g.delete_element el
    elsif motor.value[1] != 0 or true
      el.attributes['class'] = [el.attributes['class'], 'blink'].compact.join ' ' 
    end
    g.delete_element '//[@inkscape:label="play"]' unless (motor.value[2] != 0 || Time.now.sec % 4 < 2)
    [REXML::XPath.first g, '//tspan'].compact.each do |tspan|
      tspan.text = motor.tagname[/\d+/]
    end
    
    
    # make a hash consisting of each top level group and their ids
    toplevel = []
    REXML::XPath.each g, 'g/g[@inkscape:label]' do |gg|
      classname = motor.tagname + '_' + gg.attributes['inkscape:label']
      gg.attributes['class'] = [gg.attributes['class'], classname].compact.join ' ' 
      toplevel << {:group => gg, :classname => classname, :label => gg.attributes['inkscape:label']}
    end
    
    # Remove all unnecessary inkscape attributes
    REXML::XPath.each g, g.xpath + '//*' do |el| 
      el.attributes.each_attribute do |attr|
        attr.remove if attr.prefix[/./]
      end
      el.attributes['id'] = nil
    end
    {:root => g, :toplevel => toplevel }
  end
  
  
  def svg_insert_motor(motor, container, options = {}, &block)
    # container will be clickable - all of it
    # container's transform is moved to a new sub group due to Firefox bug
    # second sub group will contain motor's transform
    # inside second group, toplevel groups are added
    # toplevel groups are replaced without having to read original SVG file again
    srm = svg_read_motor(motor)

    g1 = REXML::Element.new 'g'
    g1.attributes['transform'] = container.attributes['transform'] 
    container.attributes['transform'] = nil
    
    g2 = REXML::Element.new 'g', g1
    g2.attributes['transform'] = srm[:root].attributes['transform']

    srm[:toplevel].each do |tt|
      if tt[:label]
        REXML::XPath.each container, container.xpath + "//[@inkscape:label='#{tt[:label]}']" do |el|
          tt[:group].attributes['transform'] = el.attributes['transform']
        end
      end
      g2.add_element tt[:group].deep_clone
    end
    
    while container.has_elements?
      container.delete_element container.elements[1]
    end
    
    container.add_element g1
    container.text = ""
		container.attributes['class'] = 'clickable'
  end	

  def svg_insert_motor_defs(defs, options = {}, &block)
    svg = Document.new File.new('app/views/svgtest/_motor.svg') 
		motordefs = REXML::XPath.first svg, '//defs'
    motordefs.each_element do |el|
      defs.add_element el.deep_clone
    end
  end	
end
