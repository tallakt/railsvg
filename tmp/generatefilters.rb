
delta = 3.141 * 2 / 60;

(0..59).each do |i|
	w = Math.sin(i * delta) * 0.5 + 0.5;
	
	puts %Q!
			<filter id="BlinkMatrix#{i}" >
				<feColorMatrix type="matrix" in="SourceGraphic"
					values="1 0 0 0 #{w}
								0 1 0 0 #{w}
								0 0 1 0 #{w}
								0 0 0 1 0" />
			</filter>
	
	!
	
end