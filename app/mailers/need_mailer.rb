class NeedMailer < ApplicationMailer
  default from: (ENV['HOST_PROPOSAL_FROM'] || 'no-reply@lelocal.dev'),
          to:   (ENV['HOST_PROPOSAL_TO']   || 'nicolas.goarant35@gmail.com')

  def notify_admin
    @need       = params[:need]
    @raw_params = params[:raw_params]

    photos = Array(params[:photos])

    photos.each_with_index do |file, i|
      # file est souvent un ActionDispatch::Http::UploadedFile
      next unless file.respond_to?(:tempfile) && file.tempfile && File.exist?(file.tempfile.path)

      original = file.respond_to?(:original_filename) ? file.original_filename.to_s : ""
      safe     = original.gsub(/[^0-9A-Za-z.\-_\s]/, '_').tr(' ', '_')
      ext      = File.extname(safe).delete_prefix('.')
      ext      = (file.content_type.to_s.split('/').last.presence || 'bin') if ext.empty?
      name     = safe.presence || "need_photo_#{i + 1}.#{ext}"

      data = File.binread(file.tempfile.path)
      mime = file.respond_to?(:content_type) ? file.content_type : "application/octet-stream"

      # Forcer une vraie pièce jointe
      attachments[name] = { mime_type: mime, content: data, content_disposition: "attachment" }
      Rails.logger.info("[NEED_MAILER] attached=#{name} size=#{data.bytesize} mime=#{mime}")
    end

    mail(subject: "Nouveau besoin en locaux")
  end
end
