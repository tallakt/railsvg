require 'rexml/document'

module WidgetHelper
  include REXML
  
  @@motorsvg = nil
  
  class SvgVisibilityAnimation 
    def initialize block
      @block = block
    end
  end
  
  class SvgBlinkAnimation 
    def initialize block
      @block = block
    end
  end
  
  class GeneralSvgWidget
    attr_writer :svg_file_name
    
    def initialize
      @animations = {}
      @preserveattrs = {}
      yield self
    end
    
    def visibility label, &block
      @animations[label] = VisibilityAnimation.new(block)
    end

    def invisibility label, &block
      @animations[label] = VisibilityAnimation.new(lambda {not block})
    end
    
    def preserve_attr label, attrname
      @preserveattrs[label] = attrname
    end

    def blink label, &block
      @animations[label] = BlinkAnimation.new(lambda {not block})
    end
  end
  
  
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
        end
      end
    end
    svg_add_clickable_filter defs
    
    # Remove all unnecessary inkscape attributes
    REXML::XPath.each doc, 'svg//*' do |el| 
      el.attributes.each_attribute do |attr|
        attr.remove if attr.prefix[/./]
      end
    end

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
                # <filter id="ClickableFilter" >
                  # <feColorMatrix type="matrix" in="SourceGraphic" values="1 0 0 0 0   0 1 0 0 0   0 0 01 0 0    0 0 0 1 0" />
                # </filter>
    clickableFilter = REXML::Document.new <<-END
              <defs>
                <filter
                   id="ClickableFilter" x="0" y="0" width="50" height="50" >
                  <feMorphology
                     id="feMorphology3446"
                     operator="dilate"
                     radius="2"
                     result="result1" />
                  <feColorMatrix
                     id="feColorMatrix3432"
                     values="0 0 0 0 1 0 0 0 0 1 0 0 0 0 0 0 0 0 1 0 "
                     in="result1" />
                  <feGaussianBlur
                     stdDeviation="1"
                     id="feGaussianBlur3426"
                     result="result0" />
                  <feMerge
                     id="feMerge3438">
                    <feMergeNode
                       inkscape:collect="always"
                       id="feMergeNode3440"
                       in="result0" />
                    <feMergeNode
                       inkscape:collect="always"
                       id="feMergeNode3444"
                       in="SourceGraphic" />
                  </feMerge>
                </filter>
                <filter id="BlinkFilter" >
                  <feColorMatrix type="matrix" in="SourceGraphic" id="blinkfiltermatrix" values="0.5 0 0 0 0   0 0.5 0 0 0  0 0 0.5 0 0    0 0 0 1 0" />
                </filter>
              </defs>
              END
    clickableFilter.root.each_element do |el|
      defs.add_element el.deep_clone
    end
  end
  
  def svg_read_motor (motor, mock_transforms)
    f = File.new('app/views/svgtest/_motor.svg')
    if not @@motorsvg or f.mtime != @@motorsvg['mtime'] or true
      @@motorsvg = {}
      @@motorsvg['doc'] = Document.new f
      @@motorsvg['mtime'] = f.mtime
      @@motorsvg['g'] = REXML::XPath.first @@motorsvg['doc'], '//g'
    end
		g = @@motorsvg['g'].deep_clone
    
    ['error', 'play'].each do |label|
      label_to_class(g, 'motor_' + motor.tagname, label)
      set_style(g, 'filter', 'none')
    end

#    g.delete_element '//[@inkscape:label="play"]' unless (motor.value[2] != 0 || Time.now.sec % 4 < 2)
    [REXML::XPath.first g, './/tspan'].compact.each do |tspan|
      tspan.text = motor.tagname[/\d+/]
    end
    
    mock_transforms.each do |label, transform|
      [REXML::XPath.first g, ".//g[@inkscape:label='#{label}']"].compact.each do |group|
        group.attributes['transform'] = transform
      end
    end
    
    # Remove all unnecessary inkscape attributes
    REXML::XPath.each g, '//*[@*]' do |el| 
      el.attributes.to_a.each do |attr|
        el.delete_attribute attr if attr.prefix[/./]
      end
      el.attributes['id'] = nil
    end
    g
  end
  
  
  def svg_insert_motor(motor, container, options = {}, &block)
    transforms = {}
    ['rotate', 'dont_rotate'].each do |label|
      [REXML::XPath.first container, ".//g[@inkscape:label='#{label}']"].compact.each do |el|
        transforms[label] = el.attributes['transform']
      end
    end
    motor_group = svg_read_motor(motor, transforms)

    while container.has_elements?
      container.delete_element container.elements[1]
    end
    
    container.add_element motor_group.deep_clone
    container.text = ""
		add_class(container, 'clickable')
    # container.add_attribute 'transforms', transforms.to_a.flatten.join('+')
  end

  
  def add_class(element, classname)
    element.attributes['class'] = [element.attributes['class'], classname].compact.join ' '
    element.attributes['id'] = element.attributes['class']
  end
  
  def label_to_class(owner_element, prefix, label)
    [XPath::first owner_element, ".//[@inkscape:label='#{label}']"].compact.each do |el|
      add_class(el, prefix + '_' + label) 
    end
  end
  
  def set_style(element, category, value) 
    h = {}
    value.split(/;\s*/).collect do |style|
      pair = style.split /\s*:\s*/
      h[pair[0]] = pair[1] if pair.length == 2
    end
    h[category] = value
    tmp = h.to_a.collect do |pair|
      pair.join ':'
    end
    tmp.join ';'
  end

  def svg_insert_motor_defs(defs, options = {}, &block)
    svg = Document.new File.new('app/views/svgtest/_motor.svg') 
		motordefs = REXML::XPath.first svg, '//defs'
    motordefs.each_element do |el|
      defs.add_element el.deep_clone
    end
  end	
end
