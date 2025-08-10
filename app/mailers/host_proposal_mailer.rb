class HostProposalMailer < ApplicationMailer
  default from: (ENV['HOST_PROPOSAL_FROM'] || 'no-reply@lelocal.dev'),
          to:   (ENV['HOST_PROPOSAL_TO']   || 'nicolas.goarant35@gmail.com')

  def notify_admin
    @space      = params[:space]
    @raw_params = params[:raw_params]

    photos = Array(params[:photos])
    Rails.logger.info("[MAILER] photos=#{photos.size} raw_params?=#{@raw_params.present?}")

    photos.each_with_index do |file, i|
      next unless file.respond_to?(:tempfile) && file.tempfile && File.exist?(file.tempfile.path)

      begin
        original = (file.respond_to?(:original_filename) && file.original_filename.present?) ? file.original_filename : nil
        ext      = original ? File.extname(original).delete_prefix('.') : nil
        mime     = file.respond_to?(:content_type) && file.content_type.present? ? file.content_type : nil
        # devine un mime si absent
        mime   ||= Marcel::MimeType.for(Pathname.new(file.tempfile.path), name: original) || "application/octet-stream"
        ext    ||= MIME::Types[mime].first&.preferred_extension || "bin"

        base     = original ? File.basename(original, ".*") : "photo_#{i+1}"
        # nom safe (pas d’accents/espace)
        base     = I18n.transliterate(base).gsub(/[^\w\-]+/, "_")
        name     = "#{base}.#{ext}"

        data = File.binread(file.tempfile.path)
        attachments[name] = { mime_type: mime, content: data, content_disposition: "attachment" }
        Rails.logger.info("[MAILER] attached=#{name} size=#{data.bytesize} mime=#{mime}")
      rescue => e
        Rails.logger.error("[MAILER] attach_error #{e.class}: #{e.message}")
      end
    end

    mail(subject: "Nouvelle proposition d'espace")
  end
end
