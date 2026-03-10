import { useState } from 'react';
import type { BoxProps } from '@mui/material/Box';
import type { CardProps } from '@mui/material/Card';

import Box from '@mui/material/Box';
import Card from '@mui/material/Card';
import Avatar from '@mui/material/Avatar';
import Dialog from '@mui/material/Dialog';
import IconButton from '@mui/material/IconButton';
import { CircularProgress, Chip, Stack, Divider } from '@mui/material';
import CardHeader from '@mui/material/CardHeader';
import Typography from '@mui/material/Typography';
import DialogContent from '@mui/material/DialogContent';

import { Iconify } from 'src/components/iconify';
import { Scrollbar } from 'src/components/scrollbar';

// ✅ Stronger typing
type Incident = {
  incidentId: number;
  notes: string;
  incidentDate: string;
  incidentTime: string;
  incidentPhotos: string[];
  incidentLocation?: {
    longitude: number;
    latitude: number;
  };
  incidentStatus?: string;
  title?: string;
  createdAt?: string;
  updatedAt?: string;
  customer: {
    name: string;
    email: string;
    csa?: string;
  };
};

type Props = CardProps & {
  title?: string;
  subheader?: string;
  list: Incident[];
  isLoading: boolean;
};

// ✅ Main container with Scrollbar and fallback state
export function IncidentTable({ title, subheader, list, isLoading, ...other }: Props) {
  return (
    <Card {...other}>
      <CardHeader title={title} subheader={subheader} sx={{ mb: 1 }} />

      <Scrollbar sx={{ maxHeight: 600 }}>
        <Box sx={{ px: 2, py: 1 }}>
          {isLoading ? (
            <Box
              sx={{
                display: 'flex',
                justifyContent: 'center',
                alignItems: 'center',
                height: 300,
              }}
            >
              <CircularProgress />
            </Box>
          ) : list.length > 0 ? (
            list.map((item) => <IncidentRecord key={item.incidentId} item={item} />)
          ) : (
            // ✅ Cleaner empty state message
            <Typography variant="subtitle1" align="center" sx={{ py: 5, color: 'text.secondary' }}>
              No incident data available
            </Typography>
          )}
        </Box>
      </Scrollbar>
    </Card>
  );
}

// ✅ Enhanced Record layout with card-like design
function IncidentRecord({ item, sx, ...other }: BoxProps & { item: Incident }) {
  const [selectedImage, setSelectedImage] = useState<string | null>(null);
  const [imageIndex, setImageIndex] = useState(0);

  const handleImageClick = (photo: string, index: number) => {
    setSelectedImage(photo);
    setImageIndex(index);
  };

  const handleCloseModal = () => {
    setSelectedImage(null);
  };

  const handleNextImage = () => {
    if (item.incidentPhotos && imageIndex < item.incidentPhotos.length - 1) {
      const nextIndex = imageIndex + 1;
      setImageIndex(nextIndex);
      setSelectedImage(item.incidentPhotos[nextIndex]);
    }
  };

  const handlePrevImage = () => {
    if (imageIndex > 0) {
      const prevIndex = imageIndex - 1;
      setImageIndex(prevIndex);
      setSelectedImage(item.incidentPhotos[prevIndex]);
    }
  };

  const formatDate = (dateString: string) => {
    try {
      return new Date(dateString).toLocaleDateString('en-US', {
        year: 'numeric',
        month: 'short',
        day: 'numeric',
      });
    } catch {
      return dateString;
    }
  };

  const getStatusColor = (status?: string) => {
    switch (status?.toLowerCase()) {
      case 'resolved':
        return 'success';
      case 'closed':
        return 'default';
      case 'pending':
      default:
        return 'warning';
    }
  };

  return (
    <>
      <Card
        sx={{
          p: 3,
          mb: 3,
          borderRadius: 2,
          boxShadow: (theme) => theme.customShadows.card,
          border: (theme) => `1px solid ${theme.palette.divider}`,
          transition: 'all 0.3s ease',
          '&:hover': {
            boxShadow: (theme) => theme.customShadows.z24,
            transform: 'translateY(-2px)',
          },
          ...sx,
        }}
      >
        {/* Header Section */}
        <Box sx={{ display: 'flex', alignItems: 'flex-start', gap: 2, mb: 2 }}>
          <Avatar
            sx={{
              bgcolor: 'primary.main',
              width: 56,
              height: 56,
              fontSize: '1.5rem',
              fontWeight: 600,
            }}
          >
            {item.customer.name.charAt(0).toUpperCase()}
          </Avatar>

          <Box sx={{ flex: 1, minWidth: 0 }}>
            <Box sx={{ display: 'flex', alignItems: 'center', gap: 1, mb: 0.5 }}>
              <Typography variant="h6" fontWeight={600} noWrap>
                {item.customer.name}
              </Typography>
              {item.incidentStatus && (
                <Chip
                  label={item.incidentStatus}
                  color={getStatusColor(item.incidentStatus) as any}
                  size="small"
                  sx={{ height: 24 }}
                />
              )}
            </Box>
            <Typography variant="body2" color="text.secondary" noWrap>
              {item.customer.email}
            </Typography>
            {item.customer.csa && (
              <Typography variant="caption" color="text.secondary">
                CSA: {item.customer.csa}
              </Typography>
            )}
          </Box>

          <Box sx={{ textAlign: 'right', flexShrink: 0 }}>
            <Typography variant="caption" color="text.secondary" display="block">
              {formatDate(item.incidentDate)}
            </Typography>
            <Typography variant="caption" color="text.secondary">
              {item.incidentTime}
            </Typography>
          </Box>
        </Box>

        <Divider sx={{ my: 2 }} />

        {/* Incident Details */}
        <Stack spacing={2}>
          {item.title && (
            <Box>
              <Typography variant="caption" color="text.secondary" fontWeight={600}>
                TITLE
              </Typography>
              <Typography variant="body1" fontWeight={500} sx={{ mt: 0.5 }}>
                {item.title}
              </Typography>
            </Box>
          )}

          <Box>
            <Typography variant="caption" color="text.secondary" fontWeight={600}>
              NOTES
            </Typography>
            <Typography variant="body2" color="text.primary" sx={{ mt: 0.5, whiteSpace: 'pre-wrap' }}>
              {item.notes || 'No notes provided'}
            </Typography>
          </Box>

          {item.incidentLocation && (
            <Box>
              <Typography variant="caption" color="text.secondary" fontWeight={600}>
                LOCATION
              </Typography>
              <Box sx={{ display: 'flex', gap: 2, mt: 0.5, flexWrap: 'wrap' }}>
                <Box sx={{ display: 'flex', alignItems: 'center', gap: 0.5 }}>
                  <Iconify icon="mdi:map-marker" width={16} />
                  <Typography variant="body2" color="text.primary">
                    Lat: {item.incidentLocation.latitude.toFixed(4)}
                  </Typography>
                </Box>
                <Box sx={{ display: 'flex', alignItems: 'center', gap: 0.5 }}>
                  <Iconify icon="mdi:longitude" width={16} />
                  <Typography variant="body2" color="text.primary">
                    Lng: {item.incidentLocation.longitude.toFixed(4)}
                  </Typography>
                </Box>
              </Box>
            </Box>
          )}

          {/* Image Gallery */}
          {item.incidentPhotos && item.incidentPhotos.length > 0 && (
            <Box>
              <Typography variant="caption" color="text.secondary" fontWeight={600} sx={{ mb: 1, display: 'block' }}>
                PHOTOS ({item.incidentPhotos.length})
              </Typography>
              <Box
                sx={{
                  display: 'grid',
                  gridTemplateColumns: {
                    xs: 'repeat(2, 1fr)',
                    sm: 'repeat(3, 1fr)',
                    md: 'repeat(4, 1fr)',
                  },
                  gap: 1.5,
                }}
              >
                {item.incidentPhotos.map((photo, index) => (
                  <Box
                    key={index}
                    onClick={() => handleImageClick(photo, index)}
                    sx={{
                      position: 'relative',
                      aspectRatio: '1',
                      borderRadius: 1.5,
                      overflow: 'hidden',
                      cursor: 'pointer',
                      border: (theme) => `2px solid ${theme.palette.divider}`,
                      transition: 'all 0.3s ease',
                      '&:hover': {
                        borderColor: 'primary.main',
                        transform: 'scale(1.05)',
                        boxShadow: (theme) => theme.customShadows.z8,
                      },
                    }}
                  >
                    <Box
                      component="img"
                      src={photo}
                      alt={`Incident photo ${index + 1}`}
                      sx={{
                        width: '100%',
                        height: '100%',
                        objectFit: 'cover',
                        transition: 'transform 0.3s ease',
                      }}
                    />
                    {item.incidentPhotos.length > 1 && (
                      <Box
                        sx={{
                          position: 'absolute',
                          top: 8,
                          right: 8,
                          bgcolor: 'rgba(0, 0, 0, 0.6)',
                          color: 'white',
                          px: 1,
                          py: 0.5,
                          borderRadius: 1,
                          typography: 'caption',
                          fontWeight: 600,
                        }}
                      >
                        {index + 1}/{item.incidentPhotos.length}
                      </Box>
                    )}
                  </Box>
                ))}
              </Box>
            </Box>
          )}

          {/* Incident ID */}
          <Box sx={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', pt: 1 }}>
            <Typography variant="caption" color="text.secondary">
              Incident ID: #{item.incidentId}
            </Typography>
          </Box>
        </Stack>
      </Card>

      {/* Image Modal */}
      <Dialog
        open={!!selectedImage}
        onClose={handleCloseModal}
        maxWidth="lg"
        fullWidth
        PaperProps={{
          sx: {
            bgcolor: 'rgba(0, 0, 0, 0.95)',
            position: 'relative',
          },
        }}
      >
        <IconButton
          onClick={handleCloseModal}
          sx={{
            position: 'absolute',
            top: 8,
            right: 8,
            zIndex: 1,
            color: 'white',
            bgcolor: 'rgba(0, 0, 0, 0.5)',
            '&:hover': {
              bgcolor: 'rgba(0, 0, 0, 0.7)',
            },
          }}
        >
          <Iconify icon="mdi:close" />
        </IconButton>

        {item.incidentPhotos && item.incidentPhotos.length > 1 && (
          <>
            <IconButton
              onClick={handlePrevImage}
              disabled={imageIndex === 0}
              sx={{
                position: 'absolute',
                left: 16,
                top: '50%',
                transform: 'translateY(-50%)',
                zIndex: 1,
                color: 'white',
                bgcolor: 'rgba(0, 0, 0, 0.5)',
                '&:hover': {
                  bgcolor: 'rgba(0, 0, 0, 0.7)',
                },
                '&.Mui-disabled': {
                  opacity: 0.3,
                },
              }}
            >
              <Iconify icon="mdi:chevron-left" width={32} />
            </IconButton>

            <IconButton
              onClick={handleNextImage}
              disabled={imageIndex === item.incidentPhotos.length - 1}
              sx={{
                position: 'absolute',
                right: 16,
                top: '50%',
                transform: 'translateY(-50%)',
                zIndex: 1,
                color: 'white',
                bgcolor: 'rgba(0, 0, 0, 0.5)',
                '&:hover': {
                  bgcolor: 'rgba(0, 0, 0, 0.7)',
                },
                '&.Mui-disabled': {
                  opacity: 0.3,
                },
              }}
            >
              <Iconify icon="mdi:chevron-right" width={32} />
            </IconButton>
          </>
        )}

        <DialogContent
          sx={{
            p: 0,
            display: 'flex',
            alignItems: 'center',
            justifyContent: 'center',
            minHeight: '70vh',
            position: 'relative',
          }}
        >
          {selectedImage && (
            <Box
              component="img"
              src={selectedImage}
              alt={`Incident photo ${imageIndex + 1}`}
              sx={{
                maxWidth: '100%',
                maxHeight: '90vh',
                objectFit: 'contain',
              }}
            />
          )}
        </DialogContent>

        {item.incidentPhotos && item.incidentPhotos.length > 1 && (
          <Box
            sx={{
              position: 'absolute',
              bottom: 16,
              left: '50%',
              transform: 'translateX(-50%)',
              display: 'flex',
              gap: 1,
              bgcolor: 'rgba(0, 0, 0, 0.5)',
              px: 2,
              py: 1,
              borderRadius: 2,
            }}
          >
            <Typography variant="caption" color="white" fontWeight={600}>
              {imageIndex + 1} / {item.incidentPhotos.length}
            </Typography>
          </Box>
        )}
      </Dialog>
    </>
  );
}